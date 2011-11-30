function grains = calcGrains(ebsd,varargin)
% 2d and 3d grain detection for EBSD data
%
%% Syntax
% [grains ebsd] = calcGrains(ebsd,'angle',10*degree)
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain
%  ebsd    - connected @EBSD data
%
%% Options
%  threshold|angle - array of threshold angles per phase of mis/disorientation in radians
%  augmentation    - bounds the spatial domain
%
%    * |'cube'|
%    * |'auto'|
%
%% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
%% See also
% grain/grain ebsd/segment2d ebsd/segment3d


%% parse input parameters

thresholds = get_option(varargin,{'angle','threshold'},15*degree,'double');

%% verify inputs

if numel(thresholds) == 1 && numel(ebsd.CS) > 1
  thresholds = repmat(thresholds,size(ebsd.CS));
end

if isa(ebsd,'GrainSet'),  ebsd = get(ebsd,'ebsd'); end

if all(isfield(ebsd.options,{'x','y','z'}))
  x_D = get(ebsd,'xyz');
  [Xt m n]  = unique(x_D(:,[3 2 1]),'first','rows'); %#ok<ASGLU>
elseif all(isfield(ebsd.options,{'x','y'}))
  x_D = get(ebsd,'xy');
  [Xt m n]  = unique(x_D(:,[2 1]),'first','rows'); %#ok<ASGLU>
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
ebsd = subsref(ebsd,m);

% get the location x of voronoi-generators D
[d,dim] = size(x_D);

%% spatial decomposition
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
    
    clear I_VD iv id ie p indx ivn
    
  case 3
    
    [Dl,Dr,sz,dz,lz] = spatialdecomposition3d(x_D,'unitcell',varargin{:});
    
    % adjacent cells, D x D
    A_D = sparse(double(Dl),double(Dr),1,d,d);
    
end

%% segmentation

% neighboured locations x_D, i.e. cells {D_l,D_r} in A_D

criterion = false(size(Dl));

for p = 1:numel(ebsd.phaseMap)
  
  % neighboured cells Dl and Dr have the same phase
  ndx = ebsd.phase(Dl) == p & ebsd.phase(Dr) == p;
  
  % now check whether the have a misorientation heigher or lower than a
  % threshold
  criterion(ndx) = true;
  
  if ebsd.phaseMap(p) > 0
    
    % due to memory we split the computation
    csndx = [uint32(0:1000000:sum(ndx)-1) sum(ndx)];
    for k=1:numel(csndx)-1
      andx = ndx & cumsum(ndx) > csndx(k) & cumsum(ndx) <= csndx(k+1);
      
      o_Dl = orientation(ebsd.rotations(Dl(andx)),ebsd.CS{p},ebsd.SS);
      o_Dr = orientation(ebsd.rotations(Dr(andx)),ebsd.CS{p},ebsd.SS);
      
      criterion(andx) = dot(o_Dl,o_Dr) > cos(thresholds(p)/2);
      
    end
  end
  
end

%%

% adjacency of cells that have no common boundary
A_Do = sparse(double(Dl(criterion)),double(Dr(criterion)),true,d,d);
A_Do = A_Do | A_Do';

ids = connectedComponents(A_Do);

A_Db = sparse(double(Dl(~criterion)),double(Dr(~criterion)),true,d,d);
A_Db = A_Db | A_Db';

%% retrieve neighbours

I_DG = sparse(1:numel(ids),double(ids),1);    % voxels incident to grains
A_G = I_DG'*A_Db*I_DG;                     % adjacency of grains

%% interior and exterior grain boundaries

sub = A_Db * I_DG & I_DG;                      % voxels that have a subgrain boundary
[i,j] = find( diag(any(sub,2))*double(A_Db) ); % all adjacence to those
sub = any(sub(i,:) & sub(j,:),2);              % pairs in a grain

A_Db_int = sparse(i(sub),j(sub),1,d,d);
A_Db_ext = A_Db - A_Db_int;                        % adjacent over grain boundray

%% create incidence graphs

% now do
switch dim
  case 3
    % construct faces as needed
    if numel(sz) == 3
      i = find(any(A_Db,2));  % voxel that are incident to grain boudaries
      [x_V,F,I_FD] = spatialdecomposition3d(sz,uint32(i(:)),dz,lz);
    else % its voronoi decomposition
      v = sz; clear sz
      F = dz; clear dz
      I_FD  = lz; clear lz;
    end
end

[ix,iy] = find(A_Db_ext);
D_Fext  = diag(sum(I_FD(:,ix) & I_FD(:,iy),2)>0);
D_Fbg   = diag(sum(abs(I_FD),2)==1);
I_FDext = (D_Fext+D_Fbg)*I_FD;

[ix,iy] = find(A_Db_int);
D_Fsub  = diag(sum(I_FD(:,ix) & I_FD(:,iy),2)>0);
I_FDsub = D_Fsub*I_FD;


%% sort edges of boundary when 2d case

switch dim
  case 2
    I_FDext = EdgeOrientation(I_FDext,F,x_V,x_D);
    I_FDsub = EdgeOrientation(I_FDsub,F,x_V,x_D);
    
    b = BoundaryFaceOrder(D,F,I_FDext,I_DG);
end

%% mean orientation and phase

[i,j] = find(I_DG);

cc = full(sum(I_DG>0,1));
cs = [0 cumsum(cc)];

phase        = ebsd.phase(i(cs(2:end)));
q            = quaternion(ebsd.rotations);
meanRotation = q(i(cs(2:end)));

for k = find( cc > 1)
  ndx = i(cs(k)+1:cs(k+1));
  meanRotation(k) = mean_CS(q(ndx),ebsd.CS{phase(k)},ebsd.SS);
end

%%

grainSet.comment  = [ebsd.comment ', thresholds: ' ...
  sprintf(['%3.1f' mtexdegchar ', '],thresholds/degree)];
grainSet.comment(end-1:end) = [];

grainSet.A_D      = logical(A_D);
grainSet.I_DG     = logical(I_DG);
grainSet.A_G      = logical(A_G);
grainSet.meanRotation = meanRotation;
% grain.rotations    = ebsd.rotations;
grainSet.phase        = phase;

%
grainSet.I_FDext  = logical(I_FDext);
grainSet.I_FDsub  = logical(I_FDsub);
% model.I_VE     = logical(I_VE);
grainSet.F        = sparse(double(F));
grainSet.V        = sparse(x_V);
grainSet.options  = struct;

[g,d] = find(I_DG');
ebsd.options.mis2mean = inverse(ebsd.rotations(d)).* meanRotation(g);

switch dim
  case 2
    
    grainSet.options.boundaryEdgeOrder = b;
    grains = Grain2d(grainSet,ebsd);
    
  case 3
    
    grains = Grain3d(grainSet,ebsd);
    
end


%% some sub-routines for 2d case
function I_ED = EdgeOrientation(I_ED,E,x_V,x_D)
% compute the orientaiton of an edge -1, 1

[e,d] = find(I_ED);

% in complex plane with x_D as point of orign
e1d = complex(x_V(E(e,1),1) - x_D(d,1), x_V(E(e,1),2) - x_D(d,2));
e2d = complex(x_V(E(e,2),1) - x_D(d,1), x_V(E(e,2),2) - x_D(d,2));

I_ED = sparse(e,d,sign(angle(e1d./e2d)),size(I_ED,1),size(I_ED,2));


function b = BoundaryFaceOrder(D,F,I_FD,I_DG)


I_FG = I_FD*I_DG;
[i,d,s] = find(I_FG);

b = cell(max(d),1);

onePixelGrain = full(sum(I_DG,1)) == 1;
[id,jg] = find(I_DG(:,onePixelGrain));
b(onePixelGrain) = D(id);
% close single cells
b(onePixelGrain) = cellfun(@(x) [x x(1)],  b(onePixelGrain),...
  'UniformOutput',false);

cs = [0 cumsum(full(sum(I_FG~=0,1)))];
for k=find(~onePixelGrain)
  ndx = cs(k)+1:cs(k+1);
  
  E1 = F(i(ndx),:);
  s1 = s(ndx); % flip edge
  E1(s1>0,[2 1]) = E1(s1>0,[1 2]);
  
  b{k} = EulerCycles(E1(:,1),E1(:,2));
  
end

