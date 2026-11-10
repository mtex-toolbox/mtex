function [grains,ebsd] = calcGrains(ebsd,varargin)
% grains reconstruction from 2d EBSD data
%
% Syntax
%
%   [grains, ebsd] = calcGrains(ebsd, 'angle', 10*degree, 'minPixel', 2, 'alpha', 3.7)
%
%   % reconstruction low and high angle grain boundaries
%   lagb = 2*degree;
%   hagb = 10*degree;
%   grains = calcGrains(ebsd,'angle',[hagb lagb])
%
%   % grains from a grainId stored with the data, e.g. imported from a file
%   grains = calcGrains(ebsd,'grainId')
%
%   % specify phase dependent thresholds
%   % thresholds follow the same order as ebsd.CSList and should have the same length
%   grains = calcGrains(ebsd,'angle',{angl_1 angle_2 angle_3})
%
%   % bridge cracks up to 30 pixels wide
%   grains = calcGrains(ebsd,'alphaCrack',15)
%
%   % keep the pores as notIndexed grains instead of filling them
%   grains = calcGrains(ebsd,'alphaPore',0)
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
%  grains - @grain2d
%  ebsd   - @EBSD with additional property grainId
%
% Options
%  angle    - misorientation angle that indicates a grain boundary
%  minPixel - minimum number of pixels that form a grain. No indexed grain
%             smaller than this is returned; the pixels of one that would be
%             are marked notIndexed
%  alpha    - fill distances into not indexed regions
%  alphaPore, alphaPocket, alphaCrack - the fill distance for the notIndexed
%             regions of that kind, in place of alpha, see notIndexedKinds.
%             alphaPore defaults to inf, so a pore is part of its grain;
%             alphaCrack to 0, so a crack stays open where alpha would
%             close it; alphaPocket to alpha
%  kinds    - the kind of every pixel, from notIndexedKinds, edited or not
%  straighten - true (default) draws the grain boundaries through filled
%             regions as straight lines, false along the bisectors between
%             the measured pixels around them
%  removeQuadruplePoints - true (default) splits every vertex where four
%             boundary segments meet into two triple points, joining the
%             diagonal pair of pixels that merges two grains, else the pair
%             the criterion connects best; false keeps the quadruple points
%  soft     - [angle delta] soft threshold instead of a hard one
%  fmc       - fast multiscale clustering method
%  mcl       - Markovian clustering algorithm
%  custom    - use a custom property for grain separation
%
% Flags
%  grainId  - connect pixels with the same ebsd.grainId instead of a
%             criterion on the orientations
%  verbose  - report what the criterion did, if it has anything to say -
%             currently only |'fmc'|, which prints its cluster hierarchy
%  delaunay - use a true circumradius-based alpha-complex (exact, not a
%             raster approximation) instead of the default morphological
%             closing to partition the spatial domain - see
%             alphaComplexMask. Useful for large alpha, where the
%             default's disk structuring element gets slow.
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
% GrainReconstruction GrainReconstructionCracks EBSD/notIndexedKinds

% TODO: we have to rotate everything to xy plane to do the reconstruction

gbc = grainBoundaryCriterion.byOptions(varargin{:});

% an indexed pixel without rotation is notIndexed, e.g. one a previous calcGrains absorbed
ebsd.phaseId(isnan(ebsd.rotations) & ebsd.isIndexed) = 1;

% a stored grainId of 0 means no grain, as it does for the output
if check_option(varargin,'grainId'), ebsd.phaseId(ebsd.grainId == 0) = 1; end

% the lattice depends on the positions alone, every decomposition below shares it
lat = ebsd.lattice;

% a criterion enforcing minPixel itself is handed the value, otherwise the
% loop below culls, after a cheap first cull with 'minPixelMethod','grid'
if gbc.handlesMinPixel
  minPixel = get_option(varargin,'minPixel',[]);
  if ~isempty(minPixel), gbc = gbc.setMinPixel(minPixel); end
else
  ebsd.phaseId(minPixelMask(ebsd,gbc,varargin{:})) = 1;
end

% Voronoi decomposition
% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices
% culling changes the map the closing runs on, so repeat until nothing re-fragments (#2574)
while true
  out = spatialDecompositionGrid(ebsd,lat,varargin{:});
  V = out.V;
  F = out.F;
  I_FD = remapIFD(out,ebsd);
  [V,F,I_FD] = splitPinches(V,F,I_FD,out);

  % determine which cells to connect
  [Dl,Dr] = find(triu(I_FD'*I_FD,1));
  [A_Db,I_DG] = gbc.segment(ebsd,Dl,Dr,varargin{:});
  % A_db - neighboring cells with (inner) grain boundary
  % I_DG - incidence matrix cells to grains

  if ~enforceMinPixel, break; end
end

% now we remove all empty grains
notEmpty = full(any(I_FD * I_DG,1)).';
I_DG = I_DG(:,notEmpty);

% compute grain ids
grainId = full(I_DG * (1:size(I_DG,2)).');

% boundaries straight through the filled cells, V0 the vertices before
V0 = V;
if get_option(varargin,'straighten',true) && ~isempty(out.inFill)
  [V,F,I_FD,V0] = straightenInFill(V,F,I_FD,grainId,out);
end

% phaseId of each grain
phaseId = full(max(I_DG' * ...
  spdiags(ebsd.phaseId,0,length(ebsd),length(ebsd)),[],2));
phaseId(phaseId==0) = 1; % why this is needed?

% compute boundary this gives
% I_FDext - faces × cells external grain boundaries
% I_FDint - faces × cells internal grain boundaries
[I_FDext, I_FDint, Fext, Fint] = calcBoundary;

qAdded = 0;
if get_option(varargin,'removeQuadruplePoints',true)
  [qAdded,qF] = removeQuadruplePoints;
end

% setup grains
[poly,inclusionId] = calcPolygonsC(I_FDext * I_DG,Fext,V);
grains = grain2d( makeBoundary(Fext,I_FDext), ...
  poly, [], ebsd.CSList, phaseId, ebsd.phaseMap, varargin{:}, 'inclusionId', inclusionId);

grains.numPixel = full(sum(I_DG,1)).';
grains.innerBoundary = makeBoundary(Fint,I_FDint);
grains.scanUnit = ebsd.scanUnit;

% the grains live in the very same reference frame as the map - the
% vertices were computed as bare coordinates and know nothing about it
grains.frame = ebsd.pos.frame;

% every grain's boundary closes: within a grain, every vertex is met by an
% even number of segments
g = repmat(grains.boundary.grainId(:),2,1);
v = reshape(repmat(grains.boundary.F,2,1),[],1);
[u,~,k] = unique(v(g > 0) + (g(g > 0) - 1) * size(V,1));
notClosed = unique(floor((u(mod(accumarray(k,1),2) == 1) - 1) / size(V,1)) + 1);
if ~isempty(notClosed)
  error('calcGrains:openBoundary','the boundary of grain %d does not close',notClosed(1));
end

% merge quadruple grains
if qAdded > 0, mergeQuadrupleGrains; end

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
[meanRotation, GOS] = accumarray(grainId(grainId>0),q(grainId>0));

% save 
grains.prop.GOS = GOS;
grains.prop.meanRotation = reshape(meanRotation,[],1);

% assign variant and parent Ids for variant-based grain computation
if check_option(varargin,'variants')
  variantId = get_option(varargin,'variants');
  grains.prop.variantId = variantId(firstD,1);
  grains.prop.parentId = variantId(firstD,2);
end

% assign a grainId to pixels entirely within a grain, 0 stays for those on a boundary
if nargout > 1
  wasNotIndexed = ~ebsd.isIndexed(:);
  ebsd.grainId = absorbInteriorPixels(grains,ebsd,grainId,lat);

  absorbed = wasNotIndexed & ebsd.grainId(:) > 0;
  if any(absorbed)
    ebsd.phaseId(absorbed)   = grains.phaseId(ebsd.grainId(absorbed));
    ebsd.rotations(absorbed) = nan;
  end
end
% ------------------------------------------------------------------------  

  function [I_FDext, I_FDint, Fext, Fint] = calcBoundary
    % distinguish between interior and exterior grain boundaries
    %
    % A_Db already holds exactly the cell pairs the grain boundary
    % criterion flagged as a boundary (see doSegmentation); it is split
    % into
    %  - A_Db_ext: the two cells ended up in different final grains
    %              (a true grain boundary)
    %  - A_Db_int: the two cells nevertheless ended up in the same final
    %              grain (e.g. a low-angle "soft" pair, or one merged
    %              away by removeQuadruplePoints) - a subgrain boundary
    % which - unlike the previous A_Db*I_DG-based derivation - is read
    % directly off the already-computed grainId, avoiding two sparse
    % matrix products over all D cells.
    D = size(I_DG,1);
    nFaces = size(I_FD,1);

    [ai,aj] = find(A_Db);
    sameGrain = grainId(ai) == grainId(aj) & grainId(ai) ~= 0;

    pairKey = @(a,b) double(a-1)*D + double(b);
    keyInt = pairKey(ai(sameGrain), aj(sameGrain));
    keyExt = pairKey(ai(~sameGrain), aj(~sameGrain));

    % incident cell pair per face, 0-padded in column 2 on the outer boundary -
    % I_FD can have all-zero rows, so index by the true face id and disambiguate
    % repeats locally; I_FDt is computed once, sparse row indexing dominates the cost
    I_FDt = I_FD.';
    [eId,fId] = find(I_FDt);
    isSecond = [false; fId(2:end) == fId(1:end-1)];
    cellPair = zeros(nFaces,2);
    cellPair(sub2ind([nFaces,2], fId, 1 + isSecond)) = eId;

    isPair = cellPair(:,2) > 0;
    isBg   = ~isPair & cellPair(:,1) > 0;

    faceKey = pairKey(cellPair(isPair,1), cellPair(isPair,2));

    isExt = isBg;
    isInt = false(nFaces,1);
    isExt(isPair) = ismember(faceKey, keyExt);
    isInt(isPair) = ismember(faceKey, keyInt);

    I_FDext = I_FDt(:,isExt).';
    I_FDint = I_FDt(:,isInt).';

    % remove vertices that are not needed anymore
    [inUse,~,F] = unique(F(isExt | isInt,:));
    V = V(inUse,:);
    V0 = V0(inUse,:);
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
    
    % ebsdPos lets the constructor orient every chain so that the grain in
    % grainId(:,1) lies to the left of the walk direction
    gB = grainBoundary(V,F,ebsdInd,grainId,ebsd.phaseId,mori,ebsd.CSList,...
      ebsd.phaseMap,ebsd.id,'ebsdPos',ebsd.pos,'V0',V0);
    gB.frame = ebsd.pos.frame;

  end


  function [qAdded,qF] = removeQuadruplePoints

    quadPoints = accumarray(reshape(Fext(full(any(I_FDext,2)),:),[],1),1) == 4;
    qAdded = 0;
    qF = zeros(0,2);

    if ~any(quadPoints), return; end
      
    % find the 4 edges connected to the quadpoints
    I_FV = sparse(repmat((1:size(Fext,1)).',1,2),Fext,ones(size(Fext)));
        
    quadPoints = find(sum(I_FV) == 4).';
    [iqF,~] = find(I_FV(:,quadPoints));
      
    % this is a length(quadPoints × 4 list of edges
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
      
    % pair the four edges - the two pairings pick out the two diagonals of the
    % four pixels meeting here, ranked by qpRank
    s = size(iqF);
    pairOf = @(o) I_FDext(iqF(sub2ind(s,(1:s(1)).',o(:,1))),:) .* ...
                  I_FDext(iqF(sub2ind(s,(1:s(1)).',o(:,4))),:) + ...
                  I_FDext(iqF(sub2ind(s,(1:s(1)).',o(:,2))),:) .* ...
                  I_FDext(iqF(sub2ind(s,(1:s(1)).',o(:,3))),:);

    orderA = qOrder;
    orderB = qOrder(:,[4 1 2 3]);
    iqDA = pairOf(orderA);
    iqDB = pairOf(orderB);

    okA = full(sum(iqDA,2)) == 2;
    okB = full(sum(iqDB,2)) == 2;

    useB = ~okA & okB;

    % B wins on the first key the two pairings differ in
    both = okA & okB;
    if any(both)
      KA = qpRank(iqDA,both); KB = qpRank(iqDB,both);
      d = (KB(both,:) > KA(both,:)) - (KB(both,:) < KA(both,:));
      [~,j] = max(d ~= 0,[],2);
      useB(both) = d(sub2ind(size(d),(1:size(d,1)).',j)) > 0;
    end

    qOrder(useB,:) = orderB(useB,:);
    iqD = iqDA;
    iqD(useB,:) = iqDB(useB,:);


    % a pair the criterion separates stays a quadruple point, so every added
    % segment is merged away and none of zero length remains
    ignore = full(sum(iqD,2)) ~= 2;
    [p,~] = find(iqD(~ignore,:).'); p = reshape(p,2,[]).';
    ignore(~ignore) = gbc.eval(ebsd,p(:,1),p(:,2)) <= 0;
    iqD(ignore,:) = [];
    quadPoints(ignore) = [];
    iqF(ignore,:) = [];
    %qV(ignore,:) = [];
    qOrder(ignore,:) = [];
    if isempty(quadPoints), return; end
    s = size(iqF);
    orderSub = @(i) sub2ind(s,(1:s(1)).',qOrder(:,i));
  
    % add an additional vertex (with the same coordinates) for each quad point
    newVid = (size(V,1) + (1:length(quadPoints))).';
    V = [V;V(quadPoints,:)];
    V0 = [V0;V0(quadPoints,:)];
  
    % include new vertex into face list, i.e. replace quadpoint -> newVid
    % element-wise, since two adjacent quadruple points share an edge and a
    % repeated row would keep only the last write (#2590)
    relF  = reshape(iqF([orderSub(1);orderSub(2)]),[],1); % edges that move
    relQP = repmat(quadPoints,2,1);           % vertex they have to give up
    relV  = repmat(newVid,2,1);               % vertex they take instead
    relCol = 1 + (Fext(relF,2) == relQP);
    Fext(sub2ind(size(Fext),relF,relCol)) = relV;
        
    %F(iqF(orderSub(1)),:) = [qV(orderSub(1)),newVid];
    %F(iqF(orderSub(2)),:) = [newVid,qV(orderSub(2))];
    sw = Fext(:,1) > Fext(:,2);
    Fext(sw,:) = fliplr(Fext(sw,:));
  
    [iqD,~] = find(iqD.'); iqD = reshape(iqD,2,[]).';
             
    % if we have different grains - we need a new boundary
    newBd = full(sum(I_DG(iqD(:,1),:) .* I_DG(iqD(:,2),:),2)) == 0;

    % add new edges
    % qF identifies them by their vertex pair, which survives any later reordering
    qF = [quadPoints(newBd),newVid(newBd)];
    Fext = [Fext; qF];
    qAdded = sum(newBd);

    % new rows to I_FDext
    I_FDext = [I_FDext; ...
      sparse(repmat((1:qAdded).',1,2), iqD(newBd,:), 1, ...
      qAdded,size(I_FDext,2))];
        
    % new empty rows to I_FDint
    %I_FDint = [I_FDint; sparse(qAdded,size(I_FDint,2))];
      
  end

  function K = qpRank(M,mask)
    % rank one candidate pairing of a quadruple point
    %
    % Every row of M selects the two pixels that pairing joins. Returns,
    % for the rows in mask, the keys compared in this order, larger first:
    %
    %  - whether the criterion connects the pair and it lies in two grains,
    %    so that joining it merges them
    %  - the grain boundary criterion on the pair
    %  - the misorientation angle of the pair, smaller first; Inf where none
    %    is defined (a notIndexed pixel, or two different phases)
    %  - the y coordinate of the lexicographically first of the two pixels,
    %    smaller first - the two diagonals of four pixels share a centroid
    %    and differ in the sign of their slope, which this reads off
    %
    % All of them read the measurements, so the outcome does not depend on
    % the order the measurements are handed over in

    c     = -inf(size(M,1),1);
    omega =  inf(size(M,1),1);
    key   =  inf(size(M,1),1);
    K = [c c -omega -key];
    if ~any(mask), return; end

    [qpD,~] = find(M(mask,:).');
    qpD = reshape(qpD,2,[]).';

    c(mask) = gbc.eval(ebsd,qpD(:,1),qpD(:,2));

    % misorientation angle, where one is defined at all
    qpOm  = inf(size(qpD,1),1);
    qpPhase = ebsd.phaseId;
    qpSame = qpPhase(qpD(:,1)) == qpPhase(qpD(:,2)) & ~isnan(qpPhase(qpD(:,1)));
    for qpP = reshape(unique(qpPhase(qpD(qpSame,1))),1,[])
      qpCS = ebsd.CSList(qpP);
      if ~isa(qpCS,'symmetry') || ~qpCS.isIndexed, continue; end
      qpSel = qpSame & qpPhase(qpD(:,1)) == qpP;
      qpOm(qpSel) = angle(orientation(ebsd.rotations(qpD(qpSel,1)),qpCS), ...
                      orientation(ebsd.rotations(qpD(qpSel,2)),qpCS));
    end
    omega(mask) = qpOm;

    qpP1 = [ebsd.pos(qpD(:,1)).x(:), ebsd.pos(qpD(:,1)).y(:)];
    qpP2 = [ebsd.pos(qpD(:,2)).x(:), ebsd.pos(qpD(:,2)).y(:)];
    qpSecond = qpP2(:,1) < qpP1(:,1) | (qpP2(:,1) == qpP1(:,1) & qpP2(:,2) < qpP1(:,2));
    qpKey = qpP1(:,2);
    qpKey(qpSecond) = qpP2(qpSecond,2);
    key(mask) = qpKey;

    m = c;
    m(mask) = c(mask) > 0 & grainId(qpD(:,1)) ~= grainId(qpD(:,2));
    K = [m c -omega -key];

  end

  function mergeQuadrupleGrains

    % find the added segments by their vertex pair, the constructor reorders them
    gB = grains.boundary;
    [found,loc] = ismember(sort(qF,2),sort(gB.F,2),'rows');

    assert(all(found),'MTEX:calcGrains:quadruplePoint',...
      ['%d of %d segments added by removeQuadruplePoints were not found ' ...
      'in the grain boundary - the merge step cannot identify them'], ...
      nnz(~found),numel(found));

    [grains, parentId] = merge(grains,gB(loc));

    % update I_DG
    I_PC = sparse(1:length(parentId),parentId,1);
    I_DG = I_DG * I_PC;

    % update grain ids by a matrix product, find would drop the all-zero rows
    grainId = full(I_DG * (1:size(I_DG,2)).');
  end

  function culled = enforceMinPixel
    % mark the pixels of the indexed grains below minPixel notIndexed, and
    % report whether there were any

    mp = get_option(varargin,'minPixel',1);
    culled = false;
    if mp <= 1, return; end

    szG = full(sum(I_DG,1)).';
    phG = full(max(I_DG' * ...
      spdiags(ebsd.phaseId,0,length(ebsd),length(ebsd)),[],2));

    % notIndexed grains are not subject to minPixel
    under = szG < mp & szG > 0 & phG > 1;
    culled = any(under);

    ebsd.phaseId(full(any(I_DG(:,under),2))) = 1;

  end

end

