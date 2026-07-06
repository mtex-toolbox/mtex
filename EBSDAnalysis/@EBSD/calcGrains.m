function [grains,grainId] = calcGrains(ebsd,varargin)
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
%   % specify phase dependent thresholds
%   % thresholds follow the same order as ebsd.CSList and should have the same length
%   grains = calcGrains(ebsd,'angle',{angl_1 angle_2 angle_3})
%
%   % Markovian clustering algorithm
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
%  minPixel         - minimum number of pixels that form a grain
%  boundary         - bounds the spatial domain ('convexhull', 'tight')
%  maxDist          - maximum distance to for two pixels to be in one grain (default inf)
%  fmc       - fast multiscale clustering method
%  mcl       - Markovian clustering algorithm
%  custom    - use a custom property for grain separation
%
% Flags
%  unitCell - omit Voronoi decomposition and treat a unitcell lattice
%  qhull    - use qHull for the Voronoi decomposition
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

gbc = getClass(varargin,'grainBoundaryCriterion',gbcAngle(varargin{:}));

% ---- minPixel: first pass to size grains ----------------------------------
% The alpha closing connects grain pixels across bridged gaps and diagonals
% (Voronoi face adjacency), which a local neighbour graph cannot see. Two
% methods to size grains for the minPixel filter:
%   'voronoi' (default) - run the full decomposition + segmentation once
%       without culling, so grain sizes match the final grains exactly. Costs
%       a second Voronoi pass but never over-culls.
%   'grid' - lazy route: connected components on the grid neighbourhood
%       (stencil + diagonals) only. Much cheaper, but may over-cull grains
%       that are only connected through bridged gaps.
minPixel = get_option(varargin,'minPixel',1);
minPixelMethod = get_option(varargin,'minPixelMethod','voronoi');
if minPixel > 1
  if strcmpi(minPixelMethod,'grid')
    gid0 = gridComponents(ebsd,gbc,varargin{:});  % grain id per pixel, 0 = none
  else
    out0  = spatialDecompositionGrid(ebsd,varargin{:});
    I_FD0 = remapIFD(out0,ebsd);
    [~,I_DG0] = doSegmentation(I_FD0,ebsd,gbc,varargin{:});
    gid0 = full(I_DG0 * (1:size(I_DG0,2)).');     % grain id per pixel (0 = none)
  end

  np0 = accumarray(gid0(gid0>0), 1, [max(gid0) 1]);  % pixels per grain
  sz  = zeros(length(ebsd),1);
  sz(gid0>0) = np0(gid0(gid0>0));                 % grain size seen by each pixel
  removed = ebsd.isIndexed(:) & sz < minPixel;    % undersized indexed pixels
  ebsd.phaseId(removed) = 1;                      % mark them notIndexed
end

% -- second pass: the actual decomposition --
out = spatialDecompositionGrid(ebsd,varargin{:});

V = out.V;
F = out.F;
I_FD = remapIFD(out,ebsd);

% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices

% determine which cells to connect
[A_Db,I_DG] = doSegmentation(I_FD,ebsd,gbc,varargin{:});
% A_db - neighboring cells with (inner) grain boundary
% I_DG - incidence matrix cells to grains

% now we remove all empty grains
notEmpty = full(any(I_FD * I_DG,1)).';
I_DG = I_DG(:,notEmpty);

% compute grain ids
%[grainId,~] = find(I_DG.');
grainId = full(I_DG * (1:size(I_DG,2)).');

% phaseId of each grain
phaseId = full(max(I_DG' * ...
  spdiags(ebsd.phaseId,0,length(ebsd),length(ebsd)),[],2));
phaseId(phaseId==0) = 1; % why this is needed?

% compute boundary this gives
% I_FDext - faces x cells external grain boundaries
% I_FDint - faces x cells internal grain boundaries
[I_FDext, I_FDint, Fext, Fint] = calcBoundary;

if check_option(varargin,'removeQuadruplePoints')
  qAdded = removeQuadruplePoints; 
end

% setup grains
try
  poly = calcPolygonsC(I_FDext * I_DG,Fext,V);
catch
  poly = calcPolygons(I_FDext * I_DG,Fext,V);
end
grains = grain2d( makeBoundary(Fext,I_FDext), ...
  poly, [], ebsd.CSList, phaseId, ebsd.phaseMap, varargin{:});

grains.numPixel = full(sum(I_DG,1)).';
grains.innerBoundary = makeBoundary(Fint,I_FDint);
grains.scanUnit = ebsd.scanUnit;

% merge quadruple grains
if check_option(varargin,'removeQuadruplePoints') && qAdded > 0
  mergeQuadrupleGrains;
end

% rotate grains back
grains = inv(ebsd.rot2Plane) * grains; %#ok<MINV>

% calc mean orientations, GOS and mis2mean
% ----------------------------------------

[d,g] = find(I_DG);

grainRange    = [0;cumsum(grains.numPixel)];        %
firstD        = d(grainRange(2:end));
phaseId       = ebsd.phaseId;
q             = quaternion(ebsd.rotations);
meanRotation  = q(firstD);

% choose between equivalent orientations in one grain such that all are
% close together
for pId = grains.indexedPhasesId
  ndx = phaseId(d) == pId;
  if ~any(ndx), continue; end
  q(d(ndx)) = project2FundamentalRegion(q(d(ndx)),ebsd.CSList(pId),meanRotation(g(ndx)));
end

% compute mean orientation and GOS
if 0
  GOS = zeros(length(grains),1); %#ok<UNRCH>
  doMeanCalc = find(grains.numPixel>1 & grains.isIndexed);
  abcd = zeros(length(doMeanCalc),4);
  for k = 1:numel(doMeanCalc)
    qind = subSet(q,d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1)));
    mq = mean(qind,'robust');
    abcd(k,:) = [mq.a mq.b mq.c mq.d];
    GOS(doMeanCalc(k)) = mean(angle(mq,qind)); 
  end
  meanRotation(doMeanCalc) = quaternion(abcd(:,1),abcd(:,2),abcd(:,3),abcd(:,4));
else
  %[meanRotation, GOS] = accumarray(grainId(grainId>0),q(grainId>0),'robust');
  [meanRotation, GOS] = accumarray(grainId(grainId>0),q(grainId>0));
end
% save 
grains.prop.GOS = GOS;
grains.prop.meanRotation = reshape(meanRotation,[],1);

% assign variant and parent Ids for variant-based grain computation
if check_option(varargin,'variants')
  variantId = get_option(varargin,'variants');
  grains.prop.variantId = variantId(firstD,1);
  grains.prop.parentId = variantId(firstD,2);
end

% Assign a grainId to pixels currently at 0 that lie entirely within one
% grain; 0 stays reserved for pixels a grain boundary passes through. Done in
% two steps (see the local functions below):
%   1) floodCandidates - propose a candidate grain for each zero pixel cheaply,
%      by flooding grain labels outward over the grid (a fjord's deep pixels
%      get the flanking grain; medial-axis pixels get no candidate).
%   2) footprintInside - verify each candidate geometrically: the pixel's whole
%      unit-cell footprint (corners nudged slightly inward for stability) must
%      lie inside the candidate grain. A pixel a boundary crosses fails and
%      stays 0. This gates out the flood's boundary-subdivided assignments.
ind0 = find(grainId == 0);
if ~isempty(ind0) && nargout > 1
  cand = floodCandidates(ebsd,grainId);      % candidate grain per pixel (0 = none)
  c0   = cand(ind0);
  sel  = c0 > 0;
  rows = ind0(sel);  gCand = c0(sel);
  inside = footprintInside(grains,ebsd,rows,gCand);
  grainId(rows(inside)) = gCand(inside);
end


  function [A_Db,I_DG] = doSegmentation(I_FD,ebsd,gbc,varargin)
    % segmentation
    %
    %
    % Output
    %  A_Db - adjacency matrix of grain boundaries
    %  A_Do - adjacency matrix inside grain connections

       
    % get pairs of neighboring cells {D_l,D_r} in A_D
    A_D = I_FD'*I_FD==1;
    [Dl,Dr] = find(triu(A_D,1));

    connect = gbc.eval(ebsd,Dl,Dr);

    % adjacency of cells that have no common boundary
    ind = connect>0;
    A_Do = sparse(double(Dl(ind)),double(Dr(ind)),connect(ind),length(ebsd),length(ebsd));
    if check_option(varargin,'mcl')
      
      param = get_option(varargin,'mcl');
      if isempty(param), param = 1.4; end
      if isscalar(param), param = [param,4]; end
  
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
    [i,j] = find( diag(any(sub,1))*double(A_Db) ); % all adjacent to those
    sub = any(sub(:,i) & sub(:,j),1);              % pairs in a grain
    
    % split grain boundaries A_Db into interior and exterior
    A_Db_int = sparse(i(sub),j(sub),1,size(I_DG,1),size(I_DG,1));
    A_Db_ext = A_Db - A_Db_int;                    % adjacent over grain boundary
    
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
            
    %  ebsdInd - [Id1,Id2] list of adjacent EBSD pixels for each segment
    ebsdInd = zeros(size(F,1),2);
    ebsdInd(fId) = eId;
          
    % compute misrotations
    mori = rotation.nan(size(F,1),1);
    isNotBoundary = all(ebsdInd,2);
    mori(isNotBoundary) = ...
      inv(ebsd.rotations(ebsdInd(isNotBoundary,2))) ...
      .* ebsd.rotations(ebsdInd(isNotBoundary,1));
    
    gB = grainBoundary(V,F,ebsdInd,grainId,ebsd.phaseId,mori,ebsd.CSList,ebsd.phaseMap,ebsd.id);
    gB.how2plot = ebsd.how2plot;

  end


  function qAdded = removeQuadruplePoints

    quadPoints = accumarray(reshape(Fext(full(any(I_FDext,2)),:),[],1),1) == 4;
    qAdded = 0;

    if ~any(quadPoints), return; end
      
    % find the 4 edges connected to the quadpoints
    I_FV = sparse(repmat((1:size(Fext,1)).',1,2),Fext,ones(size(Fext)));
        
    quadPoints = find(sum(I_FV) == 4).';
    [iqF,~] = find(I_FV(:,quadPoints));
      
    % this is a length(quadPoints x 4 list of edges
    iqF = reshape(iqF,4,length(quadPoints)).';
      
    % find the 4 vertices adjacent to each quadruple point
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
    %qV(ignore,:) = [];
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

function gid = gridComponents(ebsd,gbc,varargin)
% lazy grain sizing: connected components of the grid neighbourhood
% (stencil + diagonals), masked by the boundary criterion. Returns a grain id
% per ebsd pixel (0 for none). Cheaper than a full decomposition but blind to
% adjacencies that only exist across alpha-bridged gaps, so it may over-cull.
[A,stencil,~] = latticeBasis(ebsd.unitCell);
pos    = [ebsd.pos.x(:), ebsd.pos.y(:)];
origin = min(pos,[],1);
ij     = round((pos - origin) / A');
nE     = size(pos,1);
isIndexed = ebsd.isIndexed(:);

ijmin = min(ij,[],1);
ijsz  = max(ij,[],1) - ijmin + 1;
ij2slot = @(IJ) (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
ij2ebsd = zeros(prod(ijsz),1);
ij2ebsd(ij2slot(ij)) = 1:nE;

% neighbourhood = stencil plus the diagonals between consecutive axis steps
% (for a 4-stencil this is the 8-neighbourhood; for hex, the 6 axial
% neighbours already cover the close-packed ring, diagonals add the rest)
diagsq = [1 1; 1 -1; -1 1; -1 -1];
nb = unique([stencil; diagsq],'rows');

P = []; Q = [];
for s = 1:size(nb,1)
  nbIJ  = ij + nb(s,:);
  inside = all(nbIJ >= ijmin & nbIJ <= ijmin+ijsz-1, 2);
  src = find(inside & isIndexed);
  dst = ij2ebsd(ij2slot(nbIJ(src,:)));
  ok  = dst > 0 & isIndexed(max(dst,1)) & dst > src;
  P = [P; src(ok)]; Q = [Q; dst(ok)]; %#ok<AGROW>
end

% merge where the criterion says same grain, split otherwise. This matches
% doSegmentation, which builds the intra-grain adjacency A_Do from connect>0.
connect = gbc.eval(ebsd,P,Q) > 0;
gid = conncomp(graph(P(connect),Q(connect),[],nE)).';
gid(~isIndexed) = 0;                              % only size indexed pixels
end

function I_FD = remapIFD(out,ebsd)
% remap the site-indexed I_FD from the decomposition onto ebsd columns:
% each site that corresponds to an ebsd pixel keeps its column, the rest
% (empty-cell notIndexed sites) are dropped, leaving zero columns.
has  = ~isnan(out.site2id);
I_FD = sparse(size(out.F,1), length(ebsd));
I_FD(:, out.site2id(has)) = out.I_FD(:, has);
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
          
  % first circle should be positive and all others negatively oriented
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

function cand = floodCandidates(ebsd,grainId)
% Propose a candidate grain for every grainId==0 pixel by flooding the grain
% labels outward over the grid from all grain-bearing pixels (multi-source
% layered BFS). Each unassigned pixel is proposed the grain that reaches it
% first (shortest grid distance through the unassigned region); a pixel reached
% by two different grains at the same distance is on the medial axis and gets
% NO proposal (stays 0). This is only a candidate - footprintInside verifies it
% geometrically. Already grain-bearing pixels keep their id. Phase-agnostic:
% indexed and notIndexed grains flood alike.
[Agrid,stencil] = latticeBasis(ebsd.unitCell);
posE = [ebsd.pos.x(:), ebsd.pos.y(:)];
ijE  = round((posE - min(posE,[],1)) / Agrid');
nEb  = size(posE,1);
ijmin = min(ijE,[],1);  ijsz = max(ijE,[],1) - ijmin + 1;
slot  = @(IJ) (IJ(:,1)-ijmin(1)) + (IJ(:,2)-ijmin(2))*ijsz(1) + 1;
cell2e = zeros(prod(ijsz),1); cell2e(slot(ijE)) = 1:nEb;

% grid neighbour edges; the stencil is symmetric so both directions appear
P = []; Q = [];
for s = 1:size(stencil,1)
  nbIJ = ijE + stencil(s,:);
  inRange = all(nbIJ >= ijmin & nbIJ <= ijmin+ijsz-1, 2);
  src = find(inRange);  dst = cell2e(slot(nbIJ(src,:)));
  ok = dst > 0;
  P = [P; src(ok)]; Q = [Q; dst(ok)]; %#ok<AGROW>
end

cand    = grainId;                              % 0 = unassigned
visited = grainId > 0;
frontier = find(visited);
while ~isempty(frontier)
  isF = false(nEb,1); isF(frontier) = true;
  msk = isF(P) & ~visited(Q);                   % frontier -> unvisited neighbour
  qc = Q(msk);  prop = cand(P(msk));
  if isempty(qc), break; end
  gmin = accumarray(qc, prop, [nEb 1], @min, 0);
  gmax = accumarray(qc, prop, [nEb 1], @max, 0);
  newv = find(gmin > 0);
  single = gmin(newv) == gmax(newv);            % reached by exactly one grain
  cand(newv(single)) = gmin(newv(single));
  visited(newv) = true;                         % tie pixels visited, stay 0
  frontier = newv(single);                      % only proposed pixels propagate
end
end

function inside = footprintInside(grains,ebsd,rows,gCand)
% Verify, for each pixel in `rows` with candidate grain id gCand, that its whole
% unit-cell footprint lies inside that candidate grain. Corners are pulled
% slightly inward toward the pixel centre so they are not sitting exactly on the
% shared lattice boundary lines (where several grains meet), which makes the
% point-in-polygon test stable. Returns a logical per row: true iff every nudged
% corner is inside the candidate grain (holes excluded); pixels a grain boundary
% crosses fail and stay 0.
%
% Speed: the grain polygon coordinates are pulled out of grains.V / grains.poly
% ONCE and fed to insidepoly as plain numeric arrays. There is no per-grain
% subscripting of the grain object (grains(...) / checkInside), which was the
% dominant cost. poly{k} is a single index loop into V that stitches any holes
% back to the outer ring (keyhole form), so insidepoly reports points in holes
% as outside automatically.
Vx = grains.allV.x;  Vy = grains.allV.y;
poly = grains.poly;                             % cell, one index loop per grain
gid  = grains.id(:);                            % grain id per poly cell

% map candidate grain id -> poly cell index
id2pos = zeros(max(gid),1); id2pos(gid) = 1:numel(gid);

nudge = 0.95;  % 1 = exact corner, <1 = inward
ucx = ebsd.unitCell.x(:);  ucy = ebsd.unitCell.y(:);
px  = ebsd.pos.x(:);       py  = ebsd.pos.y(:);
cx  = px(rows);            cy  = py(rows);

inside = false(numel(rows),1);
for gg = unique(gCand(:)).'
  sel = find(gCand == gg);
  pk  = poly{id2pos(gg)};                        % vertex-index loop of this grain
  Px  = Vx(pk);  Py = Vy(pk);
  allin = true(numel(sel),1);
  for k = 1:numel(ucx)
    qx = cx(sel) + nudge*ucx(k);                 % nudged corner k for these pixels
    qy = cy(sel) + nudge*ucy(k);
    allin = allin & insidepoly(qx, qy, Px, Py);
  end
  inside(sel) = allin;
end
end

