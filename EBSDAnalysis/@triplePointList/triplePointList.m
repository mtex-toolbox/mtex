classdef triplePointList < phaseList & dynProp
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
    id = zeros(0,1)      % indices of the vertices in grains.V
    V = zeros(0,2)       % vertices x,y coordinates
    grainId = zeros(0,3) % id's of the neigbouring grains to a face
    boundaryId = zeros(0,3)  % id's of the neigbouring ebsd data to a face    
  end
   
  properties (Dependent = true)
    misorientation % misorientation between adjecent measurements to a boundary
    x              % x coordinates of the vertices of the grains
    y              % y coordinates of the vertices of the grains
  end
  
  methods
    function tP = triplePointList(id,V,grainId,boundaryId,phaseId,phaseMap,CSList)
      
      if nargin == 0, return; end
      
      tP.id = id;
      tP.V = V;
      tP.grainId = grainId;
      tP.boundaryId = boundaryId;      
      tP.phaseId = phaseId;
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
        
        tP.V = [tP.V;ntP.V];
        tP.grainId = [tP.grainId; ntP.grainId];
        tP.ebsdId = [tP.ebsdId; ntP.ebsdId];
        tP.misrotation = [tP.misrotation;ntP.misrotation];
        tP.phaseId = [tP.phaseId; ntP.phaseId];        
  
      end
      
      % remove duplicates
      [~,ind] = unique(tP.F,'rows');      
      tP = tP.subSet(ind);
      
    end
       
    function x = get.x(tP)
      x = tP.V(:,1);
    end
    
    function y = get.y(tP)
      y = tP.V(:,2);
    end
    
    function out = hasPhase(tP,phase1,phase2,phase3)
      
      if nargin == 2
        out = tP.hasPhaseId(convert2Id(phase1));
      elseif nargin == 3
        out = hasPhaseId(tP,convert2Id(phase1),convert2Id(phase2));
      else
        out = hasPhaseId(tP,convert2Id(phase1),convert2Id(phase2),convert2Id(phase3));
      end
      
      function phId = convert2Id(ph)
        
        if ischar(ph)
          alt_mineral = cellfun(@num2str,num2cell(tP.phaseMap),'Uniformoutput',false);
          ph = ~cellfun('isempty',regexpi(tP.mineralList(:),['^' ph])) | ...
            strcmpi(alt_mineral(:),ph);
          phId = find(ph,1);        
        elseif isa(ph,'symmetry')
          phId = find(cellfun(@(cs) cs==ph,tP.CSList));
        else
          phId = find(ph == tP.phaseMap);
        end
        
      end
      
    end
    
    function out = hasPhaseId(tP,varargin)
      
      
      ids = unique([varargin{:}]);
      counts = histc([varargin{:}],ids);
      
      out = true(size(tP));
      for i = 1:length(ids);
     
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
