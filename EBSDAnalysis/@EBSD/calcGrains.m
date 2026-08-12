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
%  grains - @grain2d
%  ebsd   - @EBSD with additional property grainId
%
% Options
%  angle    - misorientation angle that indicates a grain boundary
%  minPixel - minimum number of pixels that form a grain
%  alpha    - fill distances into not indexed regions
%  soft     - [angle delta] soft threshold instead of a hard one
%  fmc       - fast multiscale clustering method
%  mcl       - Markovian clustering algorithm
%  custom    - use a custom property for grain separation
%
% Flags
%  verbose  - report what the criterion did, if it has anything to say -
%             currently only |'fmc'|, which prints its cluster hierarchy
%  delaunay - use a true circumradius-based alpha-complex (exact, not a
%             raster approximation) instead of the default morphological
%             closing to partition the spatial domain - see
%             spatialDecompositionAlpha.m. Useful for large alpha, where
%             the default's disk structuring element gets slow.
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
% GrainReconstruction GrainReconstructionAdvanced GrainReconstructionMCL

% TODO: we have to rotate everything to xy plane to do the reconstruction

% extract grain boundary criterion
%
% A criterion object passed in always wins. Otherwise 'fmc' selects the
% fast multiscale clustering criterion, as this function's own help and
% GrainReconstructionAdvanced have documented all along - without this the
% documented call silently fell through to plain angle thresholding and
% returned a different segmentation without saying so.
if check_option(varargin,{'fmc','FMC'})
  gbc = getClass(varargin,'grainBoundaryCriterion',gbcFMC(varargin{:}));
elseif check_option(varargin,'soft')
  gbc = getClass(varargin,'grainBoundaryCriterion',gbcSoft(varargin{:}));
else
  gbc = getClass(varargin,'grainBoundaryCriterion',gbcAngle(varargin{:}));
end

% first pass:
% mark pixels that would become grains smaller than minPixel as notIndexed
%
% Criteria that enforce minPixel themselves are handed the value instead
% and this pass is skipped: it is a second full segmentation, which for a
% global criterion such as gbcFMC means running the whole clustering twice
% only to find that it has already dealt with the undersized regions.
if gbc.handlesMinPixel

  minPixel = get_option(varargin,'minPixel',[]);
  if ~isempty(minPixel), gbc = gbc.setMinPixel(minPixel); end

else

  removed = minPixelMask(ebsd,gbc,varargin{:});
  ebsd.phaseId(removed) = 1;

end

% second pass: Voronoi decomposition
% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices
if check_option(varargin,'delaunay')
  out = spatialDecompositionAlpha(ebsd,varargin{:});
else
  out = spatialDecompositionGrid(ebsd,varargin{:});
end
V = out.V;
F = out.F;
I_FD = remapIFD(out,ebsd);

% determine which cells to connect
[A_Db,I_DG] = doSegmentation(I_FD,ebsd,gbc,varargin{:});
% A_db - neighboring cells with (inner) grain boundary
% I_DG - incidence matrix cells to grains

% now we remove all empty grains
notEmpty = full(any(I_FD * I_DG,1)).';
I_DG = I_DG(:,notEmpty);

% compute grain ids
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
  [qAdded,qPairs,qF] = removeQuadruplePoints;
end

% setup grains
try
  [poly,inclusionId] = calcPolygonsC(I_FDext * I_DG,Fext,V);
catch
  [poly,inclusionId] = calcPolygons(I_FDext * I_DG,Fext,V);
end
grains = grain2d( makeBoundary(Fext,I_FDext), ...
  poly, [], ebsd.CSList, phaseId, ebsd.phaseMap, varargin{:}, 'inclusionId', inclusionId);

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

% assign a grainId to pixels that ended up entirely within a grain;
% grainId=0 stays reserved for pixels a grain boundary passes through (see
% private/absorbInteriorPixels)
if nargout > 1
  wasNotIndexed = ~ebsd.isIndexed(:);
  ebsd.grainId = absorbInteriorPixels(grains,ebsd,grainId);

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

    % incident cell pair per face (0-padded in column 2 for faces with
    % only one incident cell, i.e. the outer boundary of the map).
    % I_FD can have all-zero rows (faces with no real-cell incidence at
    % all, e.g. a Voronoi face entirely between dummy/exterior sites), so
    % unlike makeBoundary's ebsdInd - built only from the already-trimmed
    % I_FDext/I_FDint, where every row has >=1 entry - fId cannot be
    % compressed into a running count; index by the true face id fId
    % itself and disambiguate repeats (2nd cell of the same face) locally.
    %
    % I_FDt (I_FD transposed) is computed once and reused both for that
    % extraction and for the final row-selection below: sparse row
    % indexing (I_FD(mask,:)) is column-major-hostile and dominates this
    % function's cost on large maps, same reason the previous
    % implementation always transposed first too.
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
      ebsd.phaseMap,ebsd.id,'ebsdPos',ebsd.pos);
    gB.how2plot = ebsd.how2plot;

  end


  function [qAdded,qPairs,qF] = removeQuadruplePoints

    quadPoints = accumarray(reshape(Fext(full(any(I_FDext,2)),:),[],1),1) == 4;
    qAdded = 0;
    qPairs = zeros(0,2);
    qF = zeros(0,2);

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
    % qF identifies them by their vertex pair, which survives any later
    % reordering of the segments - see mergeQuadrupleGrains
    qF = [quadPoints(newBd),newVid(newBd)];
    Fext = [Fext; qF];
    qAdded = sum(newBd);

    % pixel pairs adjacent to each newly added boundary edge, in the same
    % order as the rows appended to Fext / I_FDext above
    qPairs = iqD(newBd,:);

    % new rows to I_FDext
    I_FDext = [I_FDext; ...
      sparse(repmat((1:qAdded).',1,2), iqD(newBd,:), 1, ...
      qAdded,size(I_FDext,2))];
        
    % new empty rows to I_FDint
    %I_FDint = [I_FDint; sparse(qAdded,size(I_FDint,2))];
      
  end

  function mergeQuadrupleGrains

    % a new boundary introduced by splitting a quadruple point is merged
    % away exactly when the same grain boundary criterion that was used
    % for the original segmentation would not consider it a boundary
    connect = gbc.eval(ebsd,qPairs(:,1),qPairs(:,2));
    toMerge = connect > 0;

    % Find the added segments by their vertex pair, not by row position.
    % removeQuadruplePoints appends them to the end of Fext, but the
    % grainBoundary constructor sorts every segment into chain walk order,
    % so gB(end-qAdded+1:end) stopped selecting them - it merged whichever
    % segments happened to land last instead, destroying real boundary.
    % The constructor permutes rows and may flip the two columns of a row,
    % but never renumbers vertices, so a sorted vertex pair identifies a
    % segment uniquely and reordering cannot break it.
    gB = grains.boundary;
    [found,loc] = ismember(sort(qF,2),sort(gB.F,2),'rows');

    assert(all(found),'MTEX:calcGrains:quadruplePoint',...
      ['%d of %d segments added by removeQuadruplePoints were not found ' ...
      'in the grain boundary - the merge step cannot identify them'], ...
      nnz(~found),numel(found));

    [grains, parentId] = merge(grains,gB(loc(toMerge)));

    % update I_DG
    I_PC = sparse(1:length(parentId),parentId,1);
    I_DG = I_DG * I_PC;

    % update grain ids; matrix product (not find, which drops all-zero
    % rows) so pixels with no assigned grain correctly stay 0, matching
    % the original grainId computation above
    grainId = full(I_DG * (1:size(I_DG,2)).');
  end

end

