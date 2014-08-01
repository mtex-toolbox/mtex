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
%  boundary        - bounds the spatial domain
%
% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
% See also
% GrainSet/GrainSet


% remove not indexed phases 
if any(any(isNotIndexed(ebsd))) && ~check_option(varargin,'keepNotIndexed')

  disp('  I''m removing all not indexed phases. The option "keepNotIndexed" keeps them.');
  ebsd = subSet(ebsd,~isNotIndexed(ebsd));
end

% remove dublicated data points
ebsd = removeDublicated(ebsd);

% subdivide the domain into cells according to the measurement locations,
% i.e. by Voronoi teselation or unit cell
[V,F,D,I_FD] = spatialDecomposition_local([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,varargin{:});
% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices

% determine which cells to connect
[A_Db,A_Do] = doSegmentation(I_FD,ebsd,varargin{:});
% A_db - neigbhouring cells with grain boundary
% A_Do - neigbhouring cells without grain boundary

grains = grain2d(ebsd,V,F,D,I_FD,A_Db,A_Do);

end

function ebsd = removeDublicated(ebsd)
  % remove duplicated data points

  % sort spatial coordinates
  [~,m,n]  = unique([ebsd.prop.y(:),ebsd.prop.x(:)],'first','rows');

  if numel(m) ~= numel(n)
    warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
  end
  
  % sort X and remove duplicated data
  ebsd = subSet(ebsd,m); 
end

function [V,F,D,I_FD] = spatialDecomposition_local(x_D,unitCell,varargin)
% decomposite the spatial domain into cells D with vertices V,
%
% Output
%  V - list of vertices
%  F - list of faces
%  I_FD - incidence matrix between faces to cells

% compute voronoi decomposition
% V - list of vertices of the Voronoi cells
% D   - cell array of Vornoi cells with centers X_D ordered accordingly
[V,D] = spatialdecomposition(x_D,unitCell,varargin{:});
    
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
[F, ~, ie] = unique(sort(F,2),'rows');

% faces incident to cells, F x D
I_FD = sparse(ie,id,1);

end

function [A_Db,A_Do] = doSegmentation(I_FD,ebsd,varargin)
% segmentation 

% extract segmentation method
grainBoundaryCiterions = dir([mtex_path '/qta/@EBSD/private/gbc*.m']);
grainBoundaryCiterions = {grainBoundaryCiterions.name};

gbc      = get_flag(regexprep(grainBoundaryCiterions,'gbc_(\w*)\.m','$1'),varargin,'angle');
gbcValue = get_option(varargin,gbc,15*degree,'double');

if numel(gbcValue) == 1 && length(ebsd.allCS) > 1
  gbcValue = repmat(gbcValue,size(ebsd.allCS));
end

% get pairs of neighbouring cells {D_l,D_r} in A_D
A_D = I_FD'*I_FD==1;
[Dl,Dr] = find(triu(A_D,1));

connect = false(size(Dl));

notIndexed = isNotIndexed(ebsd);

for p = 1:numel(ebsd.phaseMap)
  
  % neighboured cells Dl and Dr have the same phase
  ndx = ebsd.phaseId(Dl) == p & ebsd.phaseId(Dr) == p;
  connect(ndx) = true;
  
  % check, whether they are indexed
  ndx = ndx & ~notIndexed(Dl) & ~notIndexed(Dr);
  
  % now check for the grain boundary criterion
  if any(ndx)
    
    connect(ndx) = feval(['gbc_' gbc],...
      ebsd.rotations,ebsd.allCS{p},Dl(ndx),Dr(ndx),gbcValue(p),varargin{:});
    
  end  
end

% adjacency of cells that have no common boundary
A_Do = sparse(double(Dl(connect)),double(Dr(connect)),true,length(ebsd),length(ebsd));
A_Do = A_Do | A_Do';

A_Db = sparse(double(Dl(~connect)),double(Dr(~connect)),true,length(ebsd),length(ebsd));
A_Db = A_Db | A_Db';

end
