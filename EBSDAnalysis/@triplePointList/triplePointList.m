classdef triplePointList < phaseList & dynProp
  % triple points or triple juctions list of grain boundaries in 2-D
  %
  % triplePointList is used to extract, analyze and visualize triple points
  % between grain boundaries in  2-D.
  %
  % Syntax
  %
  %   % creates an empty list of triple points
  %   tP = triplePointList() 
  %
  %   % extracts all triple points from a list of grains
  %   tP = grains.triplePointList 
  %
  
  % properties with as many rows as data
  properties
    id = zeros(0,1)           % indices of the vertices in grains.V
    grainId = zeros(0,3)      % id's of the neigbouring grains to a face
    boundaryId = zeros(0,3)   % id's of the neigbouring ebsd data to a face
    nextVertexId = zeros(0,3) % id's of the neighbouring segment vertices
    allV = zeros(0,2)         % vertices x,y coordinates
  end
   
  properties (Dependent = true)
    misorientation % misorientation between adjecent measurements to a boundary
    x              % x coordinates of the vertices of the grains
    y              % y coordinates of the vertices of the grains
    angles         % boundary segement angles at the triple points
    V              % vertices x,y coordinates
  end
  
  methods
    function tP = triplePointList(id,allV,grainId,boundaryId,phaseId,nextVertexId,phaseMap,CSList)
      
      if nargin == 0, return; end
      
      tP.id = id;
      tP.allV = allV;
      tP.grainId = grainId;
      tP.boundaryId = boundaryId;      
      tP.phaseId = phaseId;
      tP.nextVertexId = nextVertexId;
      tP.phaseMap = phaseMap;
      tP.CSList = CSList;
      
      % sort grainId such that first phaseId1 <= phaseId2
      %doSort = gB.phaseId(:,1) > gB.phaseId(:,2) | ...
      %  (gB.phaseId(:,1) == gB.phaseId(:,2) & gB.grainId(:,1) > gB.grainId(:,2));
      %gB.phaseId(doSort,:) = fliplr(gB.phaseId(doSort,:));
      %gB.ebsdId(doSort,:) = fliplr(gB.ebsdId(doSort,:));
      %gB.grainId(doSort,:) = fliplr(gB.grainId(doSort,:));
    
    end

    function tP = cat(dim,varargin)
      
      tP = cat@dynProp(dim,varargin{:});

      for k = 2:numel(varargin)

        ntP = varargin{k};
        
        tP.id = [tP.id;ntP.id];
        tP.grainId = [tP.grainId; ntP.grainId];
        tP.boundaryId = [tP.boundaryId; ntP.boundaryId];
        %tP.ebsdId = [tP.ebsdId; ntP.ebsdId];
        %tP.misrotation = [tP.misrotation;ntP.misrotation];
        tP.phaseId = [tP.phaseId; ntP.phaseId];        
        tP.nextVertexId = [tP.nextVertexId; ntP.nextVertexId];
        
      end
      
    end
    
    function v = get.V(tP)
      v = tP.allV(tP.id,:);
    end
    
    function x = get.x(tP)
      x = tP.V(:,1);
    end
    
    function y = get.y(tP)
      y = tP.V(:,2);
    end
    
    function omega = get.angles(tP)
      
      % get the three end vertices
      iV = tP.nextVertexId;

      % compute the angles between them
      dx = reshape(tP.allV(iV,1),[],3) - repmat(tP.V(:,1),1,3);
      dy = reshape(tP.allV(iV,2),[],3) - repmat(tP.V(:,2),1,3);

      omega = sort(atan2(dy,dx),2);
      omega = mod(diff(omega(:,[1:3,1]),1,2),2*pi);
      
    end
    
    function out = hasPhase(tP,phase1,phase2,phase3)
      
      if nargin == 2
        out = tP.hasPhaseId(tP.name2id(phase1));
      elseif nargin == 3
        out = hasPhaseId(tP,tP.name2id(phase1),tP.name2id(phase2));
      else
        out = hasPhaseId(tP,tP.name2id(phase1),tP.name2id(phase2),tP.name2id(phase3));
      end
      
    end
    
    function out = hasPhaseId(tP,varargin)
      
      [ids,~,m] = unique([varargin{:}]);
      counts = accumarray(m,1);
      
      out = true(size(tP));
      for i = 1:length(ids)
     
        tmp = tP.phaseId == ids(i);
        
        % not indexed phase should include outer border as well          
        if ids(i) > 0 && ischar(tP.CSList{ids(i)})
          tmp = tmp | tP.phaseId == 0;
        end
        
        out = out & sum(tmp,2) >= counts(i);
        
      end      
    end

    function out = hasGrain(tP,grainId,grainId2)
      
      if isa(grainId,'grain2d'), grainId = grainId.id;end
      
      if nargin == 2
        
        out = any(ismember(tP.grainId,grainId),2);
        
      else
        
        out = tP.hasGrain(grainId) & tP.hasGrain(grainId2);
        
      end
      
    end
    
  end

end
