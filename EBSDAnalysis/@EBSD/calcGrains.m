function [grains,grainId,mis2mean] = calcGrains(ebsd,varargin)
% grains reconstruction from 2d EBSD data
%
% Syntax
%
%   [grains, ebsd.grainId] = calcGrains(ebsd,'angle',10*degree)
%
%   % reconstruction low and high angle grain boundaries
%   lagb = 2*degree;
%   hagb = 10*degree;
%   grains = calcGrains(ebsd,'angle',[hagb lagb])
%
%   % allow grains to grow into not indexed regions
%   grains = calcGrains(ebsd('indexed'),'angle',10*degree) 
%
%   % do not allow grains to grow into not indexed regions
%   grains = calcGrains(ebsd,'unitCell')
%
%   % follow non convex outer boundary
%   grains = calcGrains(ebsd,'boundary','tight')
%
%   % markovian clustering algorithm
%   p = 1.5;    % inflation power (default = 1.4)
%   maxIt = 10; % number of iterations (default = 4)
%   delta = 5*degree % variance of the threshold angle
%   grains = calcGrains(ebsd,'method','mcl',[p maxIt],'soft',[angle delta])
%
% Input
%  ebsd   - @EBSD
%
% Output
%  grains       - @grain2d
%  ebsd.grainId - grainId of each pixel
%
% Options
%  threshold, angle - array of threshold angles per phase of mis/disorientation in radians
%  boundary         - bounds the spatial domain ('convexhull', 'tight')
%  maxDist          - maximum distance to for two pixels to be in one grain (default inf)
%  fmc       - fast multiscale clustering method
%  mcl       - markovian clustering algorithm
%  custom    - use a custom property for grain separation
%
% Flags
%  unitCell - omit voronoi decomposition and treat a unitcell lattice
%
% References
%
% * F.Bachmann, R. Hielscher, H. Schaeben, Grain detection from 2d and 3d
% EBSD data - Specification of the MTEX algorithm: Ultramicroscopy, 111,
% 1720-1733, 2011
%
% * C. McMahon, B. Soe, A. Loeb, A. Vemulkar, M. Ferry, L. Bassman,
%   Boundary identification in EBSD data with a generalization of fast
%   multiscale clustering, <https://doi.org/10.1016/j.ultramic.2013.04.009
%   Ultramicroscopy, 2013, 133:16-25>.
%
% See also
% GrainReconstruction GrainReconstructionAdvanced

% subdivide the domain into cells according to the measurement locations,
% i.e. by Voronoi teselation or unit cell
[V,F,I_FD] = spatialDecomposition([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,varargin{:});
% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices

% determine which cells to connect
[A_Db,I_DG] = doSegmentation(I_FD,ebsd,varargin{:});
% A_db - neigbhouring cells with grain boundary
% I_DG - incidence matrix cells to grains

% compute grain ids
[grainId,~] = find(I_DG.'); ebsd.prop.grainId = grainId;

% setup grains
grains = grain2d(ebsd,V,F,I_DG,I_FD,A_Db,varargin{:});

% merge quadruple grains
if check_option(varargin,'removeQuadruplePoints') && grains.qAdded > 0

  gB = grains.boundary; gB = gB(length(gB)+1-(1:grains.qAdded));
  toMerge = false(size(gB));
       
  for iPhase = ebsd.indexedPhasesId
    
    % restrict to the same phase
    iBd = all(gB.phaseId == iPhase,2);    
    
    if ~any(iBd), continue; end
        
    % check for misorientation angle
    toMerge(iBd) = angle(gB(iBd).misorientation) < 5 * degree;
    
  end
  
  [grains, parentId] = merge(grains,gB(toMerge));
  
  % update I_DG
  I_PC = sparse(1:length(parentId),parentId,1);
  I_DG = I_DG * I_PC;
  
  % update grain ids
  [grainId,~] = find(I_DG.'); ebsd.prop.grainId = grainId;
    
end

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


% TODO: this can be done more efficiently using accumarray

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


function [A_Db,I_DG] = doSegmentation(I_FD,ebsd,varargin)
% segmentation 
%
%
% Output
%  A_Db - adjecency matrix of grain boundaries
%  A_Do - adjecency matrix inside grain connections

% extract segmentation method
grainBoundaryCiterions = dir([mtex_path '/EBSDAnalysis/@EBSD/private/gbc*.m']);
grainBoundaryCiterions = {grainBoundaryCiterions.name};

gbc      = get_flag(regexprep(grainBoundaryCiterions,'gbc_(\w*)\.m','$1'),varargin,'angle');
gbcValue = get_option(varargin,{gbc,'threshold','delta'},15*degree,'double');

if numel(gbcValue) == 1 && length(ebsd.CSList) > 1
  gbcValue = repmat(gbcValue,size(ebsd.CSList));
end

% get pairs of neighbouring cells {D_l,D_r} in A_D
A_D = I_FD'*I_FD==1;
[Dl,Dr] = find(triu(A_D,1));

if check_option(varargin,'maxDist') 
  xyDist = sqrt((ebsd.prop.x(Dl)-ebsd.prop.x(Dr)).^2 + ...
    (ebsd.prop.y(Dl)-ebsd.prop.y(Dr)).^2);

  dx = sqrt(sum((max(ebsd.unitCell)-min(ebsd.unitCell)).^2));
  maxDist = get_option(varargin,'maxDist',3*dx);
  % maxDist = get_option(varargin,'maxDist',inf);
else
  maxDist = 0;
end

connect = zeros(size(Dl));

for p = 1:numel(ebsd.phaseMap)
  
  % neighboured cells Dl and Dr have the same phase
  if maxDist > 0
    ndx = ebsd.phaseId(Dl) == p & ebsd.phaseId(Dr) == p & xyDist < maxDist;
  else
    ndx = ebsd.phaseId(Dl) == p & ebsd.phaseId(Dr) == p;
  end
  
  connect(ndx) = true;
  
  % check, whether they are indexed
  ndx = ndx & ebsd.isIndexed(Dl) & ebsd.isIndexed(Dr);
  
  % now check for the grain boundary criterion
  if any(ndx)
    
    connect(ndx) = feval(['gbc_' gbc],...
      ebsd.rotations,ebsd.CSList{p},Dl(ndx),Dr(ndx),gbcValue,varargin{:});
    
  end  
end

% adjacency of cells that have no common boundary
ind = connect>0;
A_Do = sparse(double(Dl(ind)),double(Dr(ind)),connect(ind),length(ebsd),length(ebsd));
if check_option(varargin,'mcl')
  
  param = get_option(varargin,'mcl');
  if isempty(param), param = 1.4; end
  if length(param) == 1, param = [param,4]; end
  
  A_Do = mclComponents(A_Do,param(1),param(2)); 
  A_Db = sparse(double(Dl),double(Dr),true,length(ebsd),length(ebsd)) & ~A_Do;
  
else
  
  A_Db = sparse(double(Dl(connect<1)),double(Dr(connect<1)),true,...
    length(ebsd),length(ebsd));
  
end
A_Do = A_Do | A_Do.';

% adjacency of cells that have a common boundary
A_Db = A_Db | A_Db.';

% compute I_DG connected components of A_Do
% I_DG - incidence matrix cells to grains
I_DG = sparse(1:length(ebsd),double(connectedComponents(A_Do)),1);


end
