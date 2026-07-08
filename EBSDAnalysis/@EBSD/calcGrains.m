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

% TODO: we have to rotate everything to xy plane to do the reconstruction

% extract grain boundary criterion
gbc = getClass(varargin,'grainBoundaryCriterion',gbcAngle(varargin{:}));

% first pass:
% mark pixels that would become grains smaller than minPixel as notIndexed
removed = minPixelMask(ebsd,gbc,varargin{:});
ebsd.phaseId(removed) = 1;    

% second pass: Voronoi decomposition
% V - list of vertices
% F - list of faces
% D - cell array of cells
% I_FD - incidence matrix faces to vertices
out = spatialDecompositionGrid(ebsd,varargin{:});
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

