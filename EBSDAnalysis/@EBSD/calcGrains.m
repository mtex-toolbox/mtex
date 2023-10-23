function [grains,grainId,mis2mean,mis2median,mis2mode] = calcGrains(ebsd,varargin)
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
%   % specify phase dependent thresholds
%   % thresholds follow the same order as ebsd.CSList and should have the same length
%   grains = calcGrains(ebsd,'angle',{angl_1 angle_2 angle_3})
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
%  qhull    - use qHull for the voronin decomposition
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
% A_db - neigbhouring cells with (inner) grain boundary
% I_DG - incidence matrix cells to grains

% compute grain ids
[grainId,~] = find(I_DG.');

% phaseId of each grain
phaseId = full(max(I_DG' * ...
  spdiags(ebsd.phaseId,0,numel(ebsd.phaseId),numel(ebsd.phaseId)),[],2));
phaseId(phaseId==0) = 1; % why this is needed?

% compute boundary this gives
% I_FDext - faces x cells external grain boundaries
% I_FDint - faces x cells internal grain boundaries
[I_FDext, I_FDint, Fext, Fint] = calcBoundary;

if check_option(varargin,'removeQuadruplePoints')
  qAdded = removeQuadruplePoints; 
end

% setup grains
grains = grain2d( makeBoundary(Fext,I_FDext), ...
  calcPolygons(I_FDext * I_DG,Fext,V), ...
  [], ebsd.CSList, phaseId, ebsd.phaseMap, varargin{:});

grains.grainSize = full(sum(I_DG,1)).';
grains.innerBoundary = makeBoundary(Fint,I_FDint);
grains.scanUnit = ebsd.scanUnit;

% merge quadruple grains
if check_option(varargin,'removeQuadruplePoints') && qAdded > 0
  mergeQuadrupleGrains;
end

% calc mean orientations, GOS and mis2mean
% ----------------------------------------

[d,g] = find(I_DG);

grainRange    = [0;cumsum(grains.grainSize)];        %
firstD        = d(grainRange(2:end));
q             = quaternion(ebsd.rotations);
meanRotation  = q(firstD);
medianRotation  = q(firstD);
modeRotation  = q(firstD);
GOS = zeros(length(grains),1);

% choose between equivalent orientations in one grain such that all are
% close together
for pId = grains.indexedPhasesId
  ndx = ebsd.phaseId(d) == pId;
  if ~any(ndx), continue; end
  q(d(ndx)) = project2FundamentalRegion(q(d(ndx)),ebsd.CSList{pId},meanRotation(g(ndx)));
end

% compute mean orientation and GOS
if 0
  doMeanCalc = find(grains.grainSize>1 & grains.isIndexed);
  abcd_mean = zeros(length(doMeanCalc),4);
  abcd_median = zeros(length(doMeanCalc),4);
  abcd_mode = zeros(length(doMeanCalc),4);
  for k = 1:numel(doMeanCalc)
    qind = subSet(q,d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1)));
    mq_mean = mean(qind,'robust');
    mq_median = median(qind,'robust');
    mq_mode = mode(qind);
    abcd_mean(k,:) = [mq_mean.a mq_mean.b mq_mean.c mq_mean.d];
    abcd_median(k,:) = [mq_median.a mq_median.b mq_median.c mq_median.d];
    abcd_mode(k,:) = [mq_mode.a mq_mode.b mq_mode.c mq_mode.d];
    GOS(doMeanCalc(k)) = mean(angle(mq_mean,qind)); 
  end
  meanRotation(doMeanCalc)=reshape(quaternion(abcd_mean'),[],1);
  medianRotation(doMeanCalc)=reshape(quaternion(abcd_median'),[],1);
  modeRotation(doMeanCalc)=reshape(quaternion(abcd_mode'),[],1);
else
  [meanRotation, GOS] = accumarray(grainId(:),q(:),'robust');
%   medianRotation = accumarray(grainId(:),q(:),'robust');
medianRotation = accumarray(grainId(:), q(:), [], @(x) medianQ(x));
%   modeRotation = accumarray(grainId(:),q(:),'robust');
modeRotation = accumarray(grainId(:), q(:), [], @(x) modeQ(x));
end
% save 
grains.prop.GOS = GOS;
grains.prop.meanRotation = reshape(meanRotation,[],1);
grains.prop.medianRotation = reshape(medianRotation,[],1);
grains.prop.modeRotation = reshape(modeRotation,[],1);

mis2mean = inv(rotation(q(:))) .* grains.prop.meanRotation(grainId(:));
mis2median = inv(rotation(q(:))) .* grains.prop.medianRotation(grainId(:));
mis2mode = inv(rotation(q(:))) .* grains.prop.modeRotation(grainId(:));

% assign variant and parent Ids for variant-based grain computation
if check_option(varargin,'variants')
    variantId = get_option(varargin,'variants');   
    grains.prop.variantId = variantId(firstD,1);
    grains.prop.parentId = variantId(firstD,2);
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
    gbcFlags = regexprep(grainBoundaryCiterions,'gbc_(\w*)\.m','$1');

    gbc      = get_flag(varargin,gbcFlags,'angle');
    gbcValue = ensurecell(get_option(varargin,{gbc,'threshold','delta'},15*degree,{'double','cell'}));

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
          ebsd.rotations,ebsd.CSList{p},Dl(ndx),Dr(ndx),gbcValue{p},varargin{:});
   
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
      A_Db = sparse(double(Dl),double(Dr),true,length(ebsd),length(ebsd));
      A_Db(A_Do~=0) = false;
  
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

  function [I_FDext, I_FDint, Fext, Fint] = calcBoundary
    % distinguish between interior and exterior grain boundaries
    
    % cells that have a subgrain boundary, i.e. a boundary with a cell
    % belonging to the same grain
    sub = ((A_Db * I_DG) & I_DG)';                 % grains x cell
    [i,j] = find( diag(any(sub,1))*double(A_Db) ); % all adjacence to those
    sub = any(sub(:,i) & sub(:,j),1);              % pairs in a grain
    
    % split grain boundaries A_Db into interior and exterior
    A_Db_int = sparse(i(sub),j(sub),1,size(I_DG,1),size(I_DG,1));
    A_Db_ext = A_Db - A_Db_int;                    % adjacent over grain boundray
    
    % create incidence graphs
    I_FDbg = diag( sum(I_FD,2)==1 ) * I_FD;
    D_Fbg  = diag(any(I_FDbg,2));
    
    [ix,iy] = find(A_Db_ext);
    D_Fext  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
    
    I_FDext = (D_Fext| D_Fbg)*I_FD;
    
    [ix,iy] = find(A_Db_int);
    D_Fsub  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
    I_FDint = D_Fsub*I_FD;
    
    % remove empty lines from I_FD, F, and V
    isExt = full(any(I_FDext,2));
    I_FDext = I_FDext.'; I_FDext = I_FDext(:,isExt).';

    isInt = full(any(I_FDint,2));
    I_FDint = I_FDint.'; I_FDint = I_FDint(:,isInt).';
      
    % remove vertices that are not needed anymore
    [inUse,~,F] = unique(F(isExt | isInt,:));
    V = V(inUse,:);
    F = reshape(F,[],2);
    Fext = F(isExt(isExt | isInt),:); % external boundary segments
    Fint = F(isInt(isExt | isInt),:); % internal boundary segments

  end

  function gB = makeBoundary(F,I_FD)

    % compute ebsdInd
    [eId,fId] = find(I_FD.');
    eId = eId(:); fId = fId(:);
      
    % replace fId that appears a second time by fId + length(F)+1
    % such that it refers to the second column
    d = diff([0;fId]);
    fId = cumsum(d>0) + (d==0)*size(F,1);
            
    %  ebsdInd - [Id1,Id2] list of adjecent EBSD pixels for each segment
    ebsdInd = zeros(size(F,1),2);
    ebsdInd(fId) = eId;
          
    % compute misrotations
    mori = rotation.nan(size(F,1),1);
    isNotBoundary = all(ebsdInd,2);
    mori(isNotBoundary) = ...
      inv(ebsd.rotations(ebsdInd(isNotBoundary,2))) ...
      .* ebsd.rotations(ebsdInd(isNotBoundary,1));
    
    gB = grainBoundary(V,F,ebsdInd,grainId,ebsd.phaseId,mori,ebsd.CSList,ebsd.phaseMap,ebsd.id);

  end


  function qAdded = removeQuadruplePoints

    quadPoints = find(accumarray(reshape(Fext(full(any(I_FDext,2)),:),[],1),1) == 4);
    qAdded = 0;

    if isempty(quadPoints), return; end
      
    % find the 4 edges connected to the quadpoints
    I_FV = sparse(repmat((1:size(Fext,1)).',1,2),Fext,ones(size(Fext)));
        
    quadPoints = find(sum(I_FV) == 4).';
    [iqF,~] = find(I_FV(:,quadPoints));
      
    % this is a length(quadPoints x 4 list of edges
    iqF = reshape(iqF,4,length(quadPoints)).';
      
    % find the 4 vertices adfacent to each quadruple point
    qV = [Fext(iqF.',1).';Fext(iqF.',2).'];
    qV = qV(qV ~= reshape(repmat(quadPoints.',8,1),2,[]));
    qV = reshape(qV,4,[]).';
        
    % compute angle with respect to quadruple point
    qOmega = reshape(atan2(V(qV,1) - V(repmat(quadPoints,1,4),1),...
      V(qV,2) - V(repmat(quadPoints,1,4),2)),[],4);
      
    % sort the angles
    [~,qOrder] = sort(qOmega,2);
      
    % find common pixels for pairs of edges - first we try 1/4 and 2/3
    s = size(iqF);
    orderSub = @(i) sub2ind(s,(1:s(1)).',qOrder(:,i));
            
    iqD = I_FDext(iqF(orderSub(1)),:) .* I_FDext(iqF(orderSub(4)),:) + ...
      I_FDext(iqF(orderSub(2)),:) .* I_FDext(iqF(orderSub(3)),:);
      
    % if not both have one common pixel
    switchOrder = full(sum(iqD,2))~= 2;
        
    % switch to 3/4 and 1/2
    qOrder(switchOrder,:) = qOrder(switchOrder,[4 1 2 3]);
    orderSub = @(i) sub2ind(s,(1:s(1)).',qOrder(:,i));
        
    iqD = I_FDext(iqF(orderSub(1)),:) .* I_FDext(iqF(orderSub(4)),:) + ...
      I_FDext(iqF(orderSub(2)),:) .* I_FDext(iqF(orderSub(3)),:);
      
    % some we will not be able to remove
    ignore = full(sum(iqD,2)) ~= 2;
    iqD(ignore,:) = [];
    quadPoints(ignore) = [];
    iqF(ignore,:) = [];
    qV(ignore,:) = [];
    qOrder(ignore,:) = [];
    s = size(iqF);
    orderSub = @(i) sub2ind(s,(1:s(1)).',qOrder(:,i));
  
    % add an additional vertex (with the same coordinates) for each quad point
    newVid = (size(V,1) + (1:length(quadPoints))).';
    V = [V;V(quadPoints,:)];
  
    % include new vertex into face list, i.e. replace quadpoint -> newVid
    Ftmp = Fext(iqF(orderSub(1)),:).';
    Ftmp(Ftmp == quadPoints.') = newVid;
    Fext(iqF(orderSub(1)),:) = Ftmp.';
  
    Ftmp = Fext(iqF(orderSub(2)),:).';
    Ftmp(Ftmp == quadPoints.') = newVid;
    Fext(iqF(orderSub(2)),:) = Ftmp.';
        
    %F(iqF(orderSub(1)),:) = [qV(orderSub(1)),newVid];
    %F(iqF(orderSub(2)),:) = [newVid,qV(orderSub(2))];
    sw = Fext(:,1) > Fext(:,2);
    Fext(sw,:) = fliplr(Fext(sw,:));
  
    [iqD,~] = find(iqD.'); iqD = reshape(iqD,2,[]).';
             
    % if we have different grains - we need a new boundary
    newBd = full(sum(I_DG(iqD(:,1),:) .* I_DG(iqD(:,2),:),2)) == 0;
      
    % add new edges
    Fext = [Fext; [quadPoints(newBd),newVid(newBd)]];
    qAdded = sum(newBd);
    
    % new rows to I_FDext
    I_FDext = [I_FDext; ...
      sparse(repmat((1:qAdded).',1,2), iqD(newBd,:), 1, ...
      qAdded,size(I_FDext,2))];
        
    % new empty rows to I_FDint
    %I_FDint = [I_FDint; sparse(qAdded,size(I_FDint,2))];
      
  end

  function mergeQuadrupleGrains
    
    gB = grains.boundary; gB = gB(length(gB)+1-(1:qAdded));
    toMerge = false(size(gB));
       
    for iPhase = ebsd.indexedPhasesId
    
      % restrict to the same phase
      iBd = all(gB.phaseId == iPhase,2);
    
      if ~any(iBd), continue; end
        
      % check for misorientation angle % TODO
      toMerge(iBd) = angle(gB(iBd).misorientation) < 5 * degree;
    
    end
  
    [grains, parentId] = merge(grains,gB(toMerge));
  
    % update I_DG
    I_PC = sparse(1:length(parentId),parentId,1);
    I_DG = I_DG * I_PC;
  
    % update grain ids
    [grainId,~] = find(I_DG.');
  end


end

function poly = calcPolygons(I_FG,F,V)
%
% Input:
%  I_FG - incidence matrix faces to grains
%  F    - list of faces
%  V    - list of vertices

poly = cell(size(I_FG,2),1);

if isempty(I_FG), return; end

% for all grains
for k=1:size(I_FG,2)
    
  % inner and outer boundaries are circles in the face graph
  EC = EulerCycles(F(I_FG(:,k)>0,:));
          
  % first cicle should be positive and all others negatively oriented
  for c = 1:numel(EC)
    if xor( c==1 , polySgnArea(V(EC{c},1),V(EC{c},2))>0 )
      EC{c} = fliplr(EC{c});
    end
  end
    
  % this is needed
  for c=2:numel(EC), EC{c} = [EC{c} EC{1}(1)]; end
  
  poly{k} = [EC{:}];
  
end

end


% Calculate the median of a list of quaternions
function qMedian = medianQ(q)
    qMedian = median(q);
end

% Calculate the mode of a list of quaternions
function qMode = modeQ(q)
    qMode = mode(q);
end