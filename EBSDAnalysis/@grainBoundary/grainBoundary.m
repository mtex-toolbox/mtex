classdef grainBoundary < phaseList & dynProp
  % grainBoundary list of grain boundaries in 2-D
  %
  % grainBoundary is used to extract, analyze and visualize grain
  % boundaries in  2-D. 
  %
  % gB = grainBoundary() creates an empty list of grain boundaries
  %
  % gB = grains.boudary() extracts boundary information
  % from a list of grains
  %
  
  % properties with as many rows as data
  properties
    F = zeros(0,2)       % list of faces - indeces to V    
    grainId = zeros(0,2) % id's of the neigbouring grains to a face
    ebsdId = zeros(0,2)  % id's of the neigbouring ebsd data to a face
    misrotation = rotation % misrotations
  end
  
  % general properties
  properties
    V = []          % vertices x,y coordinates            
    scanUnit = 'um' % unit of the vertice coordinates
    triplePoints    % triple points
  end
  
  properties (Dependent = true)
    misorientation % misorientation between adjecent measurements to a boundary
    direction      % direction of the boundary segment
    midPoint       % x,y coordinates of the midpoint of the segment
    I_VF           % incidence matrix vertices - edges
    I_FG           % incidence matrix edges - grains
    A_F            % adjecency matrix edges - edges
    A_V            % adjecency matrix vertices - vertices
    segmentId      % connected component id
    segmentSize    % number of faces that form a segment
    x              % x coordinates of the vertices of the grains
    y              % y coordinates of the vertices of the grains    
  end
  
  methods
    function gB = grainBoundary(V,F,I_FD,ebsd,grainsPhaseId)
      %
      % Input
      %  V - [x,y] list of vertices
      %  F - [v1,v2] list of boundary segments
      %  I_FD - incidence matrix boundary segments vs. cells
      %  ebsd -
      %  grainPhaseId - 
      %
      %
      
      if nargin == 0, return; end
      
      % remove empty lines from I_FD and F
      isBoundary = any(I_FD,2);
      gB.F = F(full(isBoundary),:);
      gB.V = V;
                  
      % compute ebsdID
      [eId,fId] = find(I_FD.');
      
      % scale fid down to 1:length(gB)
      d = diff([0;fId]);      
      fId = cumsum(d>0) + (d==0)*size(gB.F,1);
            
      gB.ebsdId = zeros(size(gB.F,1),2);
      gB.ebsdId(fId) = eId;      
            
      % compute grainId
      gB.grainId = zeros(size(gB.F,1),2);
      gB.grainId(fId) = ebsd.grainId(eId);
      
      % compute phaseId
      gB.phaseId = zeros(size(gB.F,1),2);
      isNotBoundary = gB.ebsdId>0;
      gB.phaseId(isNotBoundary) = ebsd.phaseId(gB.ebsdId(isNotBoundary));
      gB.phaseMap = ebsd.phaseMap;
      gB.CSList = ebsd.CSList;
      
      % sort ebsdId such that first phaseId1 <= phaseId2
      doSort = gB.phaseId(:,1) > gB.phaseId(:,2) | ...
        (gB.phaseId(:,1) == gB.phaseId(:,2) & gB.grainId(:,1) > gB.grainId(:,2));
      gB.phaseId(doSort,:) = fliplr(gB.phaseId(doSort,:));
      gB.ebsdId(doSort,:) = fliplr(gB.ebsdId(doSort,:));
      gB.grainId(doSort,:) = fliplr(gB.grainId(doSort,:));
      
      % compute misrotations
      gB.misrotation = rotation.id(size(gB.F,1),1);
      isNotBoundary = all(gB.ebsdId,2);
      gB.misrotation(isNotBoundary) = ...
        inv(ebsd.rotations(gB.ebsdId(isNotBoundary,2))) ...
        .* ebsd.rotations(gB.ebsdId(isNotBoundary,1));

      % compute triple points
      gB.triplePoints = gB.calcTriplePoints(grainsPhaseId);
      
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
      
      % remove duplicates
      [~,ind] = unique(gB.F,'rows');      
      gB = gB.subSet(ind);
      
    end
    
    
    function mori = get.misorientation(gB)
            
      mori = orientation(gB.misrotation,gB.CS{:});
      mori.antipodal = equal(checkSinglePhase(gB),2);
      
    end
    
    function dir = get.direction(gB)      
      v1 = vector3d(gB.V(gB.F(:,1),1),gB.V(gB.F(:,1),2),zeros(length(gB),1),'antipodal');
      v2 = vector3d(gB.V(gB.F(:,2),1),gB.V(gB.F(:,2),2),zeros(length(gB),1));
      dir = normalize(v1-v2);
    end
    
    function x = get.x(gB)
      x = gB.V(unique(gB.F(:)),1);
    end
    
    function y = get.y(gB)
      y = gB.V(unique(gB.F(:)),2);
    end
    
    function xy = get.midPoint(gB)
      xyA = gB.V(gB.F(:,1),:);
      xyB = gB.V(gB.F(:,2),:);
      xy = 0.5 * (xyA + xyB);
    end
    
    function I_VF = get.I_VF(gB)
      [i,~,f] = find(gB.F);
      I_VF = sparse(f,i,1,size(gB.V,1),size(gB.F,1));
    end

    function I_FG = get.I_FG(gB)
      ind = gB.grainId>0;
      iF = repmat(1:size(gB.F,1),1,2);
      I_FG = sparse(iF(ind),gB.grainId(ind),1);
    end   
    
    function A_F = get.A_F(gB)
      I_VF = gB.I_VF; %#ok<PROP>
      A_F = I_VF.' * I_VF; %#ok<PROP>
      n = length(A_F);
      A_F(sub2ind(size(A_F),1:n,1:n)) = 0;
    end
    
    function A_V = get.A_V(gB)
      A_V = sparse(gB.F(:,1),gB.F(:,2),1:size(gB.F,1),size(gB.V,1),size(gB.V,1)) ...
        + sparse(gB.F(:,2),gB.F(:,1),1:size(gB.F,1),size(gB.V,1),size(gB.V,1));
    end
    
    %function tp = get.triplePoints(gB)
       
    %end
    
    function segmentId = get.segmentId(gB)
      segmentId = connectedComponents(gB.A_F).';
    end
    
    function segmentSize = get.segmentSize(gB)
      segId = gB.segmentId;
      [bincounts,ind] = histc(segId,unique(segId));
      segmentSize = bincounts(ind);
    end
    
    function out = hasPhase(gB,phase1,phase2)
      
      if nargin == 2
        out = gB.hasPhaseId(convert2Id(phase1));
      else
        out = hasPhaseId(gB,convert2Id(phase1),convert2Id(phase2));
      end
      
      function phId = convert2Id(ph)
        
        if ischar(ph)
          alt_mineral = cellfun(@num2str,num2cell(gB.phaseMap),'Uniformoutput',false);
          ph = ~cellfun('isempty',regexpi(gB.mineralList(:),['^' ph])) | ...
            strcmpi(alt_mineral(:),ph);
          phId = find(ph,1);        
        elseif isa(ph,'symmetry')
          phId = find(cellfun(@(cs) cs==ph,gB.CSList));
        else
          phId = find(ph == gB.phaseMap);
        end
        
      end
      
    end
    
    function out = hasPhaseId(gB,phaseId,phaseId2)
      
      if isempty(phaseId), out = false(size(gB)); return; end
      
      if nargin == 2
        out = any(gB.phaseId == phaseId,2);
      
        % not indexed phase should include outer border as well
        if phaseId > 0 && ischar(gB.CSList{phaseId}), out = out | any(gB.phaseId == 0,2); end
               
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
    
  end

end
