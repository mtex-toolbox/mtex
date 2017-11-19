function [grains,grainId,mis2mean] = calcGrains(ebsd,varargin)
% grains reconstruction from 2d EBSD data
%
% Syntax
%   grains = calcGrains(ebsd,'angle',10*degree)
%   grains = calcGrains(ebsd,'unitCell')
%
% Input
%  ebsd   - @EBSD
%
% Output
%  grains  - @grain2d
%
% Options
%  threshold|angle - array of threshold angles per phase of mis/disorientation in radians
%  boundary        - bounds the spatial domain
%
% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
% See also
% 

% subdivide the domain into cells according to the measurement locations,
% i.e. by Voronoi teselation or unit cell
[V,F,I_FD] = spatialDecomposition([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,varargin{:});
% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices

% determine which cells to connect
[A_Db,A_Do] = doSegmentation(I_FD,ebsd,varargin{:});
% A_db - neigbhouring cells with grain boundary
% A_Do - neigbhouring cells without grain boundary

% compute grains as connected components of A_Do
% I_DG - incidence matrix cells to grains
I_DG = sparse(1:length(ebsd),double(connectedComponents(A_Do)),1);

% compute grain ids
[grainId,~] = find(I_DG.'); ebsd.prop.grainId = grainId;

% setup grains
grains = grain2d(ebsd,V,F,I_DG,I_FD,A_Db);

% calc mean orientations, GOS and mis2mean
% ----------------------------------------

[d,g] = find(I_DG);

grainRange    = [0;cumsum(grains.grainSize)];        %
firstD        = d(grainRange(2:end));
q             = quaternion(ebsd.rotations);
meanRotation  = q(firstD);
GOS = zeros(length(grains),1);

% choose between equivalent orientations in one grain such that all are
% close together
for p = grains.indexedPhasesId
  ndx = ebsd.phaseId(d) == p;
  if ~any(ndx), continue; end
  q(d(ndx)) = project2FundamentalRegion(q(d(ndx)),ebsd.CSList{p},meanRotation(g(ndx)));
end

% compute mean orientation and GOS
doMeanCalc = find(grains.grainSize>1 & grains.isIndexed);
for k = 1:numel(doMeanCalc)
  
  qind = subSet(q,d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1)));
  mq = mean(qind,'robust');
  meanRotation = setSubSet(meanRotation,doMeanCalc(k),mq);
  GOS(doMeanCalc(k)) = mean(angle(mq,qind));
  
end

% save 
grains.prop.GOS = GOS;
grains.prop.meanRotation = reshape(meanRotation,[],1);
mis2mean = inv(rotation(q(:))) .* grains.prop.meanRotation(grainId(:));

end


function [A_Db,A_Do] = doSegmentation(I_FD,ebsd,varargin)
% segmentation 

% extract segmentation method
grainBoundaryCiterions = dir([mtex_path '/EBSDAnalysis/@EBSD/private/gbc*.m']);
grainBoundaryCiterions = {grainBoundaryCiterions.name};

gbc      = get_flag(regexprep(grainBoundaryCiterions,'gbc_(\w*)\.m','$1'),varargin,'angle');
gbcValue = get_option(varargin,{gbc,'threshold'},15*degree,'double');

if numel(gbcValue) == 1 && length(ebsd.CSList) > 1
  gbcValue = repmat(gbcValue,size(ebsd.CSList));
end

% get pairs of neighbouring cells {D_l,D_r} in A_D
A_D = I_FD'*I_FD==1;
[Dl,Dr] = find(triu(A_D,1));

connect = false(size(Dl));

for p = 1:numel(ebsd.phaseMap)
  
  % neighboured cells Dl and Dr have the same phase
  ndx = ebsd.phaseId(Dl) == p & ebsd.phaseId(Dr) == p;
  connect(ndx) = true;
  
  % check, whether they are indexed
  ndx = ndx & ebsd.isIndexed(Dl) & ebsd.isIndexed(Dr);
  
  % now check for the grain boundary criterion
  if any(ndx)
    
    connect(ndx) = feval(['gbc_' gbc],...
      quaternion(ebsd.rotations),ebsd.CSList{p},Dl(ndx),Dr(ndx),gbcValue(p),varargin{:});
    
  end  
end

% adjacency of cells that have no common boundary
A_Do = sparse(double(Dl(connect)),double(Dr(connect)),true,length(ebsd),length(ebsd));
A_Do = A_Do | A_Do';

A_Db = sparse(double(Dl(~connect)),double(Dr(~connect)),true,length(ebsd),length(ebsd));
A_Db = A_Db | A_Db';

end

