classdef orientationMapping < handle
  %ORIENTATIONMAPPING Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    CS1 = crystalSymmetry % crystal symmetry
    CS2 = specimenSymmetry % crystal symmetry of a second phase for misorientations    
  end
   
  methods
    
    function oM = orientationMapping(ebsd,varargin)
      if nargin == 0, return; end
      if isa(ebsd,'EBSD') || isa(ebsd,'grain2d')
        oM.CS1 = ebsd.CS;
      elseif isa(ebsd,'orientation')
        oM.CS1 = ebsd.CS;
        oM.CS2 = ebsd.SS;
      elseif isa(ebsd,'grainBoundary')
        [oM.CS1,oM.CS2] = deal(ebsd.CS{:});
        oM.CS1 = oM.CS1;
        oM.CS2 = oM.CS2;
      elseif isa(ebsd,'symmetry')
        oM.CS1 = ebsd;
      end
      
      if nargin > 1 && isa(varargin{1},'symmetry')
        oM.CS2 = varargin{1};
      end
      
      if oM.CS1.id == oM.CS1.Laue.id
        disp(' ')
        disp('  Hint: You might want to use the point group')
        disp(['  ' char(oM.CS1.properGroup) ' for colorcoding!']);
        disp(' ')
      end
      
    end
      
    function plot(oM,varargin)
      % plot an color bar

      oS = newODFSectionPlot(oM(1).CS1,oM(1).CS2,varargin{:});

      ori = oS.makeGrid(varargin{:});
      rgb = oM.orientation2color(ori);
      
      if numel(rgb) == length(ori)
        varargin = [{'smooth'},varargin];
      else
        varargin = [{'surf'},varargin];
      end
      plot(oS,rgb,varargin{:});
      
    end        
  end
  
  methods (Abstract = true)
    c = orientation2color(oM,ori,varargin)
  end
end

