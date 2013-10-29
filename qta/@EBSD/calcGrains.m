function grains = calcGrains(ebsd,varargin)
% 2d and 3d construction of GrainSets from spatially indexed EBSD data
%
% Syntax
%   grains = calcGrains(ebsd,'angle',10*degree)
%
% Input
%  ebsd   - @EBSD
%
% Output
%  grains  - @Grain2d | @Grain3d
%
% Options
%  threshold|angle - array of threshold angles per phase of mis/disorientation in radians
%  augmentation    - bounds the spatial domain
%
%    * |'cube'|
%    * |'auto'|
%
% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
% See also
% GrainSet/GrainSet

% ------------- parse input parameters -------------------

grainBoundaryCiterions = dir([mtex_path '/qta/@EBSD/private/gbc*.m']);
grainBoundaryCiterions = {grainBoundaryCiterions.name};

gbc      = get_flag(regexprep(grainBoundaryCiterions,'gbc_(\w*)\.m','$1'),varargin,'angle');
gbcValue = get_option(varargin,gbc,15*degree,'double');

% --------------- remove not indexed phases ----------------

if any(isNotIndexed(ebsd)) && ~check_option(varargin,'keepNotIndexed')
  disp('  I''m removing all not indexed phases. The option "keepNotIndexed" keeps them.');
  
  ebsd = subSet(ebsd,~isNotIndexed(ebsd));
  
end

% ------------------ verify inputs --------------------------

if numel(gbcValue) == 1 && length(ebsd.CS) > 1
  gbcValue = repmat(gbcValue,size(ebsd.CS));
end

if all(isfield(ebsd.prop,{'x','y','z'}))
  x_D = [ebsd.prop.x(:),ebsd.prop.y(:),ebsd.prop.z(:)];
  [Xt,m,n]  = unique(x_D(:,[3 2 1]),'first','rows'); %#ok<ASGLU>
elseif all(isfield(ebsd.prop,{'x','y'}))
  x_D = [ebsd.prop.x(:),ebsd.prop.y(:)];
  [Xt,m,n]  = unique(x_D(:,[2 1]),'first','rows'); %#ok<ASGLU>
else
  error('mtex:GrainGeneration','no Spatial Data!');
end
clear Xt

% check for duplicated data points
if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
end
clear n

% sort X
x_D = x_D(m,:);

% sort ebsd accordingly
ebsd = subSet(ebsd,m);
clear m

% get the location x of voronoi-generators D
[d,dim] = size(x_D);

% ----------------spatial decomposition ---------------------------
% decomposite the spatial domain into cells D with vertices x_V,

switch dim
  case 2
    
    [x_V,D] = spatialdecomposition(x_D,ebsd.unitCell,varargin{:});
    
    % now we need some adjacencies and incidences
    iv = [D{:}];            % nodes incident to cells D
    id = zeros(size(iv));   % number the cells
    
    p = [0; cumsum(cellfun('prodofsize',D))];
    for k=1:numel(D), id(p(k)+1:p(k+1)) = k; end
    
    % next vertex
    indx = 2:numel(iv)+1;
    indx(p(2:end)) = p(1:end-1)+1;
    ivn = iv(indx);
    
    % edges list
    F = [iv(:), ivn(:)];
    % should be unique (i.e one edge is incident to two cells D)
    [F, b, ie] = unique(sort(F,2),'rows');
    
    % edges incident to cells, E x D
    I_FD = sparse(ie,id,1);
    
    % vertices incident to cells, V x D
    I_VD = sparse(iv,id,1,size(x_V,1),d);
    
    % adjacent cells, D x D
    A_D = triu(I_VD'*I_VD>1,1);
    
    [Dl,Dr] = find(A_D);  % list of cells
    
    clear I_VD iv id ie p b indx ivn
    
  case 3
    
    [Dl,Dr,sz,dz,lz] = spatialdecomposition3d(x_D,ebsd.unitCell,varargin{:});
    
    %     adjacent cells, D x D
    A_D = sparse(double(Dl),double(Dr),1,d,d);
    
    A_D = triu(A_D | A_D',1);
    [Dl,Dr] = find(A_D);
    
    clear x_D
    
end

% --------------------- segmentation ------------------------------

% neighboured locations x_D, i.e. cells {D_l,D_r} in A_D

criterion = false(size(Dl));

notIndexed = isNotIndexed(ebsd);

for p = 1:numel(ebsd.phaseMap)
  
  % neighboured cells Dl and Dr have the same phase
%   ndx = ebsd.phase(Dl) == ebsd.phaseMap(p) & ebsd.phase(Dr) == ebsd.phaseMap(p);
  ndx = ebsd.phaseId(Dl) == p & ebsd.phaseId(Dr) == p;
  criterion(ndx) = true;
  
  % check, whether they are indexed
  ndx = ndx & ~notIndexed(Dl) & ~notIndexed(Dr);
  
  % now check for the grain boundary criterion
  if any(ndx)
    
    criterion(ndx) = feval(['gbc_' gbc],...
      ebsd.rotations,ebsd.CS{p},Dl(ndx),Dr(ndx),gbcValue(p),varargin{:});
    
  end
  
end

clear ndx

% ------------------------------------------------------------

% adjacency of cells that have no common boundary
A_Do = sparse(double(Dl(criterion)),double(Dr(criterion)),true,d,d);
A_Do = A_Do | A_Do';

A_Db = sparse(double(Dl(~criterion)),double(Dr(~criterion)),true,d,d);
A_Db = A_Db | A_Db';

clear Dl Dr criterion notIndexed p k

% ----------------- retrieve neighbours --------------------------

I_DG = sparse(1:d,double(connectedComponents(A_Do)),1);    % voxels incident to grains
% % A_G = I_DG'*A_Db*I_DG;                     % adjacency of grains

% clear A_Do

% ----------- interior and exterior grain boundaries ------------

sub = (A_Db * I_DG & I_DG)';                      % voxels that have a subgrain boundary
[i,j] = find( diag(any(sub,1))*double(A_Db) ); % all adjacence to those
sub = any(sub(:,i) & sub(:,j),1);              % pairs in a grain

A_Db_int = sparse(i(sub),j(sub),1,d,d);
A_Db_ext = A_Db - A_Db_int;                        % adjacent over grain boundray

clear sub i j

% ----------------- create incidence graphs ----------------------

% now do
switch dim
  case 2
    I_FDbg = diag(sum(I_FD,2)==1)*I_FD;
  case 3
    % construct faces as needed
    if numel(sz) == 3
      i = find(any(A_Db_int,2) | any(A_Db_ext,2));  % voxel that are incident to grain boudaries
      [x_V,F,I_FD,I_FDbg] = spatialdecomposition3d(sz,uint32(i(:)),dz,lz);
    else % its voronoi decomposition
      v = sz; clear sz
      F = dz; clear dz
      I_FD  = lz; clear lz;
      
      D_Fbg = sum(abs(I_FD),2)==1;
      I_FDbg = D_Fbg * I_FD;
    end
end

D_Fbg   = diag(any(I_FDbg,2));
clear I_FDbg

[ix,iy] = find(A_Db_ext);
clear A_Db_ext
D_Fext  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);

I_FDext = (D_Fext| D_Fbg)*I_FD;
clear D_Fext D_Fbg I_FDbg

[ix,iy] = find(A_Db_int);
clear A_Db_int
D_Fsub  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
I_FDint = D_Fsub*I_FD;
clear I_FD I_FDbg D_Fsub ix iy

% ------------ mean orientation and phase --------------------------

[d,g] = find(I_DG);

grainSize     = full(sum(I_DG>0,1));
grainRange    = [0 cumsum(grainSize)];
firstD        = d(grainRange(2:end));
phaseId       = ebsd.phaseId(firstD);
q             = quaternion(ebsd.rotations);
meanRotation  = q(firstD);


indexedPhases = ~cellfun('isclass',ebsd.CS(:),'char');
for p = find(indexedPhases)'
  ndx = ebsd.phaseId(d) == p; % ebsd.phaseMap(p);
  q(d(ndx)) = project2FundamentalRegion(...
    q(d(ndx)),ebsd.CS{p},meanRotation(g(ndx)));
  
  % mean may be inaccurate for some grains and should be projected again
  % any(sparse(d(ndx),g(ndx),angle(q(d(ndx)),meanRotation(g(ndx))) > getMaxAngle(ebsd.CS{p})/2))
end



doMeanCalc    = find(grainSize(:)>1 & indexedPhases(phaseId));
cellMean      = cell(size(doMeanCalc));
for k = 1:numel(doMeanCalc)
  cellMean{k} = d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1));
end
cellMean = cellfun(@mean,partition(q,cellMean),'uniformoutput',false);

meanRotation(doMeanCalc) = [cellMean{:}];

clear grainSize grainRange indexedPhases doMeanCalc cellMean q g qMean


% -----------------------------------------------------------

% set up grainStruct
grainStruct.V    = x_V;            clear x_V;
grainStruct.F    = F;              clear F;
grainStruct.I_FDext  = I_FDext;        clear I_FDext;
grainStruct.I_FDint  = I_FDint;        clear I_FDint;
grainStruct.I_DG     = logical(I_DG);  clear I_DG;
grainStruct.A_Db     = logical(A_Db);   clear A_D;
grainStruct.A_Do     = logical(A_Do);   clear A_D;

grainStruct.ebsd = ebsd;
grainStruct.meanRotation = meanRotation;  clear meanRotation;

switch dim
  case 2    
    
    grainStruct.D = D;
    grains = Grain2d(grainStruct);
    
  case 3
    
    grains = Grain3d(ebsd);
    
end

