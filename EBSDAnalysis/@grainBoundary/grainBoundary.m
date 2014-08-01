classdef grainBoundary < phaseList & dynProp %& misorientationAnalysis
  % grainBoundary list of grain boundaries in 2-D
  %
  % grainBoundary is used to extract, analyze and visualize grain
  % boundaries in  2-D. 
  %
  % gB = grainBoundary() creates an empty list of grain boundaries
  %
  % gB = grains.boudary() extracted the all the boundary information
  % from a list of grains
  %
  % 

  % properties with as many rows as data
  properties
    F = zeros(0,2)       % list of faces - indeces to V
    id = []              % face id
    ebsdId = zeros(0,2)  % id's of the neigbouring ebsd data to a face
    isInt = false(0,0)   % internal or not internal grain boundary
    misrotation = rotation % misrotations
  end
  
  % general properties
  properties
    V = [] % vertices x,y coordinates    
  end
  
  methods
    function gB = grainBoundary(V,F,I_FD,ebsd)
      
      if nargin == 0, return; end
      
      % remove empty lines from I_FD and F
      isBoundary = any(I_FD,2);
      %I_FD = I_FD(isBoundary,:);
      
      gB.V = V;
      gB.F = F(full(isBoundary),:);
      gB.id = 1:size(F,1);
  
      % compute ebsdID
      [eId,fId] = find(I_FD.');
      
      % scale fid down to 1:length(gB)
      d = diff([0;fId]);      
      fId = cumsum(d>0) + (d==0)*length(gB);
            
      gB.ebsdId = zeros(length(gB),2);
      gB.ebsdId(fId) = eId;      
      
      % compute phaseId
      gB.phaseId = zeros(length(gB),2);
      isNotBoundary = gB.ebsdId>0;
      gB.phaseId(isNotBoundary) = ebsd.phaseId(gB.ebsdId(isNotBoundary));
      gB.phaseMap = ebsd.phaseMap;
      gB.CSList = ebsd.CSList;
      
      % sort ebsdId such that first phaseId1 <= phaseId2
      doSort = gB.phaseId(:,1) > gB.phaseId(:,2);
      gB.phaseId(doSort,:) = fliplr(gB.phaseId(doSort,:));
      gB.ebsdId(doSort,:) = fliplr(gB.ebsdId(doSort,:));
      
      % compute misrotations
      gB.misrotation = rotation(idquaternion(length(gB),1));
      isNotBoundary = all(gB.ebsdId,2);
      gB.misrotation(isNotBoundary) = ...
        inv(ebsd.rotations(gB.ebsdId(isNotBoundary,1))) ...
        .* ebsd.rotations(gB.ebsdId(isNotBoundary,2));
    
    end

    
    function mori = misorientation(gB)
            
      mori = orientation(gB.misrotation,gB.CS{:});
      
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
          ph = ~cellfun('isempty',regexpi(gB.mineralList(:),ph)) | ...
            strcmpi(alt_mineral,ph);
          phId = find(ph,1);        
        elseif isa(ph,'symmetry')
          phId = find(cellfun(@(cs) cs==ph,gB.CSList));
        else
          phId = find(ph == gB.phaseMap);
        end
        
      end
      
    end
    
    function out = hasPhaseId(gB,phaseId,phaseId2)
      
      if nargin == 2
        out = any(gB.phaseId == phaseId,2);
      
        % not indexed phase should include outer border as well
        if ischar(gB.CSList{phaseId}), out = out | any(gB.phaseId == 0,2); end
        
      elseif phaseId == phaseId2
        
        out = all(gB.phaseId == phaseId,2);
        
      else
        
        out = gB.hasPhaseId(phaseId) & gB.hasPhaseId(phaseId2);
        
      end
      
    end

  end

end
