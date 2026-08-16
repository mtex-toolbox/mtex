classdef grainBoundary < phaseList & dynProp
%
% Variables of type grainBoundary represent lists of grain boundary
% segments. Those are typically generated during grain reconstruction and
% are accessible via
%
%   grains.boundary
%
% Each grain boundary segment stores many properties: its position within
% the map, the ids of the adjacent grains, the ids of the adjacent EBSD
% measurements, the grain boundary misorientation, etc. These properties
% are explained in more detail in the section <BoundaryProperties.html
% boundary properties>.
%
% Class Properties
%  V            - [x,y] list of vertices 
%  scanUnit     - scanning unit (default - um)
%  triplePoints - @triplePointList
%  F            - list of boundary segments as ids to V
%  grainId      - id's of the neighboring grains to a boundary segment
%  ebsdId       - id's of the neighboring ebsd data to a boundary segment
%  misrotation  - misrotation between neighboring ebsd data to a boundary segment
%
% Dependent Class Properties
%  misorientation - disorientation between neighboring ebsd data to a boundary segment
%  direction      - direction of the boundary segment as @vector3d
%  midPoint       - x,y coordinates of the midpoint of the segments
%  I_VF           - incidence matrix vertices - edges
%  I_FG           - incidence matrix edges - grains
%  A_F            - adjacency matrix edges - edges
%  A_V            - adjacency matrix vertices - vertices
%  componentId    - connected component id
%  componentSize  - number of segments that belong to the component
%  chainId        - id of the chain a segment belongs to
%  chainSize      - number of segments of that chain
%  isChainStart   - segment is the first of its chain
%  isChainEnd     - segment is the last of its chain
%  isClosed       - the chain of this segment closes onto itself
%  arcLength      - length along the chain up to the end of this segment
%  chainLength    - total length of the chain this segment belongs to
%  chainV         - vertex ids of all chains, separated by NaN
%  isJunction     - vertex is a junction - indexes allV
%  junctionId     - ids of the junction vertices
%  x              - x coordinates of the vertices of the grains
%  y              - y coordinates of the vertices of the grains    
%  z              - z coordinates of the vertices of the grains    
%

  
  % properties with as many rows as data
  properties
    F = zeros(0,2)       % list of faces - indices to V    
    grainId = zeros(0,2) % id's of the neighboring grains to a face
    ebsdId = zeros(0,2)  % id's of the neighboring ebsd data to a face
    misrotation = rotation % misrotations
  end
  
  % general properties
  properties
    scanUnit = 'um' % unit of the vertex coordinates
    triplePoints = triplePointList  % triple points
  end
  
  properties (Dependent = true)
    misorientation % misorientation between adjacent measurements to a boundary
    direction      % direction of the boundary segment
    midPoint       % x,y coordinates of the midpoint of the segment
    I_VF           % incidence matrix vertices - edges
    I_FG           % incidence matrix edges - grains
    A_F            % adjacency matrix edges - edges
    A_V            % adjacency matrix vertices - vertices
    componentId    % connected component id
    componentSize  % number of faces that form a segment
    chainId        % id of the chain a segment belongs to
    chainSize      % number of segments of that chain
    isChainStart   % segment is the first of its chain
    isChainEnd     % segment is the last of its chain
    isClosed       % the chain of this segment closes onto itself
    arcLength      % length along the chain up to the end of this segment
    chainLength    % total length of the chain this segment belongs to
    chainV         % vertex ids of all chains, separated by NaN
    isJunction     % vertex is a junction - indexes allV
    junctionId     % ids of the junction vertices
    x              % x coordinates of the vertices of the grains
    y              % y coordinates of the vertices of the grains
    z              % z coordinates of the vertices of the grains
    allV           % list of all vertices
    V              % vertices that are part of the grain boundary
    N              % normal direction of the pseudo3d data    
    frame          % the specimen reference frame (carried by allV)
    how2plot       % default plotting convention
  end
  
  methods
    function gB = grainBoundary(V,F,ebsdInd,grainId,phaseId,mori,CSList,phaseMap,ebsdId,varargin)
      %
      % Input
      %  V       - [x,y] list of vertices
      %  F       - [v1,v2] list of boundary segments
      %  ebsdInd - [Id1,Id2] list of adjacent EBSD pixels for each segment
      %  mori    - misorientation between adjacent EBSD pixels for each segment
      %  grainId - ebsd.grainId
      %  phaseId - ebsd.phaseId
      %  CSList   - 
      %  phaseMap - 
      
      if nargin == 0, return; end

      % ensure V is vector3d
      if ~isa(V,'vector3d'), V = vector3d.byXYZ(V); end
      
      % assign properties - the normal lives in the very same frame as
      % the vertices
      N0 = zvector;
      N0.frame = V.frame;
      gB.triplePoints = struct('allV',V,'N',N0);
      gB.F = F;
      gB.misrotation = mori;
      gB.CSList = CSList;
      gB.phaseMap = phaseMap;
      gB.misrotation = mori;
      gB.ebsdId = ebsdInd;
      if nargin >= 9 && ~isempty(ebsdId) % store ebsd_id instead of index
        gB.ebsdId(ebsdInd>0) = ebsdId(ebsdInd(ebsdInd>0));
      end

      % compute boundary grainId and phaseId
      gB.grainId = zeros(size(F,1),2);
      gB.grainId(ebsdInd>0) = grainId(ebsdInd(ebsdInd>0));
      
      gB.phaseId = zeros(size(F,1),2);
      gB.phaseId(ebsdInd>0) = phaseId(ebsdInd(ebsdInd>0));

      % sort columns such that first phaseId1 <= phaseId2
      doSort = gB.phaseId(:,1) > gB.phaseId(:,2) | ...
        (gB.phaseId(:,1) == gB.phaseId(:,2) & gB.grainId(:,1) > gB.grainId(:,2));
      if any(doSort)
        gB.phaseId(doSort,:) = fliplr(gB.phaseId(doSort,:));
        gB.ebsdId(doSort,:) = fliplr(gB.ebsdId(doSort,:));
        gB.grainId(doSort,:) = fliplr(gB.grainId(doSort,:));
        gB.misrotation(doSort) = inv(gB.misrotation(doSort));

        % leftOriented says the caller built F such that the pre-sort first
        % grain is already on its left - as grain2d does, since it derives F
        % from the positively wound poly loops. Swapping the grain columns
        % swaps left and right, so F has to follow.
        if check_option(varargin,'leftOriented')
          gB.F(doSort,:) = fliplr(gB.F(doSort,:));
        end
      end

      % bring the segments into walk order - this has to happen before the
      % triple points are computed, as those reference segment ids
      if ~check_option(varargin,'noOrder')

        % the left/right convention needs to know on which side of a segment
        % the grain grainId(:,1) sits, which gB itself cannot tell
        ebsdPos = get_option(varargin,'ebsdPos',[]);
        if ~isempty(ebsdPos)

          ebsdInd(doSort,:) = fliplr(ebsdInd(doSort,:));

          mid = mean(V(F),2);
          pos = mid;
          isInner = ebsdInd(:,1) > 0;
          pos(isInner) = ebsdPos(ebsdInd(isInner,1));

          % along the outer border grainId(:,1) is 0 and has no pixel, so
          % mirror the pixel of the other side through the segment midpoint
          isOuter = ~isInner & ebsdInd(:,2) > 0;
          pos(isOuter) = 2*mid(isOuter) - ebsdPos(ebsdInd(isOuter,2));

          varargin = [varargin,{'leftPos',pos}];
        end

        gB = gB.order(varargin{:});
      end

      % compute triple points
      if ~check_option(varargin,'noTriplePoints')
        gB.triplePoints = gB.calcTriplePoints;
      end
    end

    function gB = cat(dim,varargin)
      
      gB = cat@dynProp(dim,varargin{:});

      for k = 2:numel(varargin)

        ngB = varargin{k};
        
        gB.F = [gB.F;ngB.F];
        gB.grainId = [gB.grainId; ngB.grainId];
        gB.ebsdId = [gB.ebsdId; ngB.ebsdId];
        gB.misrotation = [gB.misrotation;ngB.misrotation];
        gB.phaseId = [gB.phaseId; ngB.phaseId];        
  
      end
      
      % remove duplicates - F is no longer canonically sorted per row, since
      % its column order now encodes the walk direction
      [~,ind] = unique(sort(gB.F,2),'rows');
      gB = gB.subSet(ind);

      % concatenating tears the chains apart, so re-establish the invariant
      gB = gB.order;

    end
    
    
    function mori = get.misorientation(gB)
      
      CS = gB.CS;
      mori = orientation(gB.misrotation,CS(1),CS(2));
      mori.antipodal = equal(checkSinglePhase(gB),2);
      
      % set not indexed orientations to nan
      if ~all(gB.isIndexed), mori(~gB.isIndexed) = NaN; end
      
    end
    
    function dir = get.direction(gB)      
      
      dir = normalize(gB.allV(gB.F(:,1)) - gB.allV(gB.F(:,2)));
      dir.antipodal = true;
      
    end
    
    function fr = get.frame(gB)
      fr = gB.allV.frame;
    end

    function gB = set.frame(gB,fr)
      gB.allV.frame = fr;
      % the triple points carry their own vertices and the normal
      gB.triplePoints.frame = fr;
    end

    function pC = get.how2plot(gB)
      pC = gB.allV.how2plot;
    end

    function gB = set.how2plot(gB,pC)
      % a convention belongs to a frame, not to data - see
      % plottingConvention.assignedToData. Releasing the frame is
      % still a legitimate gesture and stays silent
      if isempty(pC)
        gB.frame = [];
      else
        plottingConvention.assignedToData(class(gB));
        plottingConvention.default(pC);
      end
    end

    function V = get.allV(gB)
      V = gB.triplePoints.allV;
    end
    
    function gB = set.allV(gB,V)
      gB.triplePoints.allV = V;
    end
    
    function V = get.V(gB)
      V = reshape(gB.triplePoints.allV(gB.F),length(gB),2);
    end
    
    function N = get.N(gB)
      N = gB.triplePoints.N;
    end
    
    function gB = set.N(gB,N)
      gB.triplePoints.N = N;
    end

    function x = get.x(gB)
      x = gB.allV.x(unique(gB.F(:)));
    end
    
    function y = get.y(gB)
      y = gB.allV.y(unique(gB.F(:)));
    end

    function y = get.z(gB)
      y = gB.allV.z(unique(gB.F(:)));
    end
    
    function m = get.midPoint(gB)      
      m = mean(gB.allV(gB.F),2);
    end
    
    function I_VF = get.I_VF(gB)
      [i,~,f] = find(gB.F);
      I_VF = sparse(f,i,true,size(gB.allV,1),size(gB.F,1));
    end

    function I_FG = get.I_FG(gB)
      ind = gB.grainId>0;
      iF = repmat(1:size(gB.F,1),1,2);
      I_FG = logical(sparse(iF(ind),gB.grainId(ind),1));
    end   
    
    function A_F = get.A_F(gB)
      I_VF = gB.I_VF; %#ok<PROP>
      A_F = I_VF.' * I_VF; %#ok<PROP>
      n = length(A_F);
      A_F(sub2ind(size(A_F),1:n,1:n)) = 0;
    end
    
    function A_V = get.A_V(gB)
      A_V = sparse(gB.F(:,1),gB.F(:,2),1:size(gB.F,1),size(gB.allV,1),size(gB.allV,1)) ...
        + sparse(gB.F(:,2),gB.F(:,1),1:size(gB.F,1),size(gB.allV,1),size(gB.allV,1));
    end
    
    %function tp = get.triplePoints(gB)
       
    %end
    
    function componentId = get.componentId(gB)
      componentId = connectedComponents(gB.A_F).';
    end
    
    function componentSize = get.componentSize(gB)
      segId = gB.componentId;
      
      [~,~,ind] = unique(segId);
      counts = accumarray(ind,1);
      componentSize = counts(ind);
      
    end
    
    function isJct = get.isJunction(gB)
      % a vertex where any number of segments other than two meet
      deg = accumarray(gB.F(:),1,[size(gB.allV,1) 1]);
      isJct = deg ~= 2 & deg > 0;
    end

    function id = get.junctionId(gB)
      id = find(gB.isJunction);
    end

    function isStart = get.isChainStart(gB)

      F = gB.F;
      if size(F,1) == 0, isStart = false(0,1); return; end

      % a chain continues only if the rows chain head to tail AND the shared
      % vertex is not a junction - without the second test two different
      % chains meeting at a junction would be welded into one
      isJct = gB.isJunction;
      isStart = [true; F(2:end,1) ~= F(1:end-1,2) | isJct(F(1:end-1,2))];

    end

    function isEnd = get.isChainEnd(gB)
      isStart = gB.isChainStart;
      isEnd = [isStart(2:end); ~isempty(isStart)];
    end

    function id = get.chainId(gB)
      id = cumsum(double(gB.isChainStart));
    end

    function s = get.chainSize(gB)
      id = gB.chainId;
      s = accumarray(id,1);
      s = s(id);
    end

    function cl = get.isClosed(gB)
      F = gB.F;
      iStart = find(gB.isChainStart);
      iEnd = find(gB.isChainEnd);
      cl = F(iEnd,2) == F(iStart,1);
      cl = cl(gB.chainId);
    end

    function l = get.arcLength(gB)
      sl = gB.segLength;
      cs = cumsum(sl);
      iStart = find(gB.isChainStart);
      base = cs(iStart) - sl(iStart);
      l = cs - base(gB.chainId);
    end

    function l = get.chainLength(gB)
      l = gB.arcLength;
      l = l(gB.isChainEnd);
      l = l(gB.chainId);
    end

    function v = get.chainV(gB)

      F = gB.F;
      n = size(F,1);
      if n == 0, v = zeros(0,1); return; end

      % every segment contributes its start vertex, every chain end adds
      % its end vertex and a NaN separator
      isEnd = gB.isChainEnd;
      ind = (1:n).' + cumsum([0; 2*double(isEnd(1:end-1))]);

      v = nan(n + 2*nnz(isEnd),1);
      v(ind) = F(:,1);
      v(ind(isEnd)+1) = F(isEnd,2);

    end

    function out = hasPhase(gB,phase1,phase2)
      
      if nargin == 2
        out = gB.hasPhaseId(gB.name2id(phase1));
      else
        out = hasPhaseId(gB,gB.name2id(phase1),gB.name2id(phase2));
      end

    end
    
    function out = hasPhaseId(gB,phaseId,phaseId2)
      
      if isempty(phaseId), out = false(size(gB)); return; end
      
      if nargin == 2
        out = any(gB.phaseId == phaseId,2);
      
        % not indexed phase should include outer border as well
        if phaseId > 0 && ~gB.CSList(phaseId).isIndexed
          out = out | any(gB.phaseId == 0,2); 
        end
               
      elseif isempty(phaseId2)
        
        out = false(size(gB));
        
      elseif phaseId == phaseId2
        
        out = all(gB.phaseId == phaseId,2);
        
      else
        
        out = gB.hasPhaseId(phaseId) & gB.hasPhaseId(phaseId2);
        
      end
      
    end

    function out = hasGrain(gB,grainId,grainId2)
      
      if isa(grainId,'grain2d'), grainId = grainId.id;end
      
      if nargin == 2
        
        out = any(ismember(gB.grainId,grainId),2);
        
      else
        
        out = gB.hasGrain(grainId) & gB.hasGrain(grainId2);
        
      end
      
    end
    
    function gB = update(gB,grains)
      
      gB.phaseId = zeros(size(gB.F,1),2);
      ind = grains.id2ind(gB.grainId);
      gB.phaseId(ind>0) = grains.phaseId(ind(ind>0));
      
    end
  end

  methods (Static = true)
      function gB = loadobj(s)
      % called by MATLAB when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
      % maybe there is nothing to do
      %if isa(s,'grainBoundary'), gB = s; return; end
      
      if isstruct(s)
        gB = grainBoundary;
        gB.triplePoints = s.triplePoints;
        gB.F = s.F;
        gB.grainId = s.grainId;
        gB.ebsdId = s.ebsdId;
        gB.misrotation = s.misrotation;
        gB.phaseId = s.phaseId;
        gB.CSList = s.CSList;
        gB.phaseMap = s.phaseMap;
        gB.prop = s.prop;
      else
        gB = s;
      end

      if isfield(gB.prop,'V')
        V = gB.prop.V;
        if isnumeric(V), V = vector3d(V(:,1),V(:,2),zeros(size(V,1),1)); end
        gB.triplePoints.allV = V;
        gB.prop = rmfield(gB.prop,'V');
      end

      % up to MTEX 5.11 the symmetries were stored as a cell array
      gB.CSList = ensureCSArray(gB.CSList);

      % files written before segments were stored in walk order. order is
      % idempotent, so this is safe on files that already satisfy it.
      gB = gB.order;

    end
    
    
  end
  
end
