classdef grainBoundary < dynProp %& misorientationAnalysis
  % grainBoundary list of grain boundaries in 2-D
  %
  % grainBoundary is used to extract, analyze and visualize grain
  % boundaries in  2-D. 
  %
  % gB = grainBoundary() creates an empty list of grain boundaries
  %
  % gB = grains.grainBoudary() extracted the all the boundary information
  % from a list of grains
  %
  % 

  properties
    grains
  end
  
  properties (Dependent = true)
    
    id                    % identification number
    
    V                     % vertices - (x,y,(z)) coordinate
    F                     % edges - vertices ids (v1,v2)
    
    ebsd                  % ebsd data assoziated with the boundaries
    
    ebsdId                %
    phaseId
    phase
    phaseMap
    CS
    allCS
    mineral                     % mineral name of the grain
    allMinerals                 % all mineral names of the data set
    mis2mean
    meanOrientation             % mean orientation of the grain
    indexedPhasesId             % id's of all non empty indexed phase 

    
    
    %phase1
    %phase2
    %CS1
    %CS2
    %mineral1
    %mineral2    
  end
  
  methods
    function gB = grainBoundary(grains)
      
      if nargin == 0, return; end
      
      gB.grains = grains;
      
    end
    
    function out = hasPhase(gB,phase)
      
      if ischar(phase)
        % find symmetry
        phase = symmetry;
      end
      
      if isa(phase,'symmetry')
        phaseId = find(cellfun(@(cs) cs==phase,gB.allCS));
      else
        phaseId = find(phase == gB.phaseMap);
      end
      
      out = gB.hasPhaseId(phaseId);           
      
    end
    
    function out = hasPhaseId(gB,phaseId)
      
      gBphId = gB.phaseId;
      out = any(gBphId == phaseId,2);
      
      % not indexed phase should include outer border as well
      if ischar(gB.allCS{phaseId}), out = out | any(gBphId == 0,2); end
      
    end

    
    function mori = calcMisorientation(gB)
      % compute the misorientations along the boundary
      
      lOri = gB.grains.ebsd(gB.ebsdIdLeft).orientations;
      rOri = gB.grains.ebsd(gB.ebsdIdRight).orientations;
      
      mori = inv(lOri) .* rOri;
      
    end
    
    function V = get.V(gB)
      
      V = gB.grains.V;
      
    end
    
    function F = get.F(gB)
      
      F = gB.grains.F;
      
    end
    
    function id = get.ebsdId(gB)
      % return ids to ebsd data neigbouring the faces
      %
      % gB.ebsdId is a Nx2 table where N is the number of faces 
            
      id = zeros(size(gB.grains.I_FD,1),2);
      
      % add indices of faces with two neibours
      ind = sum(gB.grains.I_FD~=0,2)==2;
                
      [ifd,~] = find(gB.grains.I_FD(ind,:).');
      
      id(ind,:) = reshape(ifd,2,[]).';
      
      % add indices of faces with one neibour
      ind = sum(gB.grains.I_FD~=0,2)==1;
                
      [ifd,~] = find(gB.grains.I_FD(ind,:).');
      
      id(ind,1) = ifd;
      
    end
    
    function id = get.phaseId(gB)
      % neigbouring phaseIds to a face
      
      id = zeros(size(gB.grains.I_FD,1),2);
      
      ebsdId = gB.ebsdId;
      
      id(ebsdId>0) = gB.ebsd.phaseId(ebsdId(ebsdId>0));
            
    end

    function ph = get.phase(gB)
      % neigbouring phase to a face
      
      ph = zeros(size(gB.grains.I_FD,1),2);
      
      ebsdId = gB.ebsdId;
      
      ph(ebsdId>0) = gB.ebsd.phase(ebsdId(ebsdId>0));
      
    end
    
    
    function CS = get.allCS(gB), CS = gB.grains.allCS; end
    
    function pm = get.phaseMap(gB), pm = gB.grains.phaseMap; end

    function ebsd = get.ebsd(gB), ebsd = gB.grains.ebsd; end
    
    
    %phase1
    %phase2
    %CS1
    %CS2
    %mineral1
    %mineral2    
      
      
    
  end
  
  

end
