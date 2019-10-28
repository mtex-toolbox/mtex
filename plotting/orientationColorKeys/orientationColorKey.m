classdef orientationColorKey < handle
  % abstract class for defining (mis)orientation color keys
  %
  % Class Properties
  %  CS1 - @crystalSymmetry
  %  CS2 - @crystalSymmetry of a second phase for misorientations
  %  antipodal - logical
  %
  % See also
  % BungeColorKey, ipfColorKey, ipfHSVKey, ipfTSLKey, ipfHKLKey, ipfSpotKey
  
  properties
    CS1 = crystalSymmetry % crystal symmetry
    CS2 = specimenSymmetry % crystal symmetry of a second phase for misorientations
    antipodal = false
  end
   
  methods
    
    function oCK = orientationColorKey(ebsd,varargin)
      if nargin == 0, return; end
      if isa(ebsd,'EBSD') || isa(ebsd,'grain2d')
        oCK.CS1 = ebsd.CS;
      elseif isa(ebsd,'orientation')
        oCK.CS1 = ebsd.CS;
        oCK.CS2 = ebsd.SS;
        oCK.antipodal = ebsd.antipodal;
      elseif isa(ebsd,'grainBoundary')
        [oCK.CS1,oCK.CS2] = deal(ebsd.CS{:});
        oCK.CS1 = oCK.CS1;
        oCK.CS2 = oCK.CS2;
        oCK.antipodal = all(diff(ebsd.phaseId,[],2)==0);
      elseif isa(ebsd,'symmetry')
        oCK.CS1 = ebsd;
      end
      
      if nargin > 1 && isa(varargin{1},'symmetry')
        oCK.CS2 = varargin{1};
      end

      oCK.antipodal = oCK.antipodal || check_option(varargin,'antipodal');

    end
      
    function plot(oCK,varargin)
      % plot an color bar

      if oCK(1).antipodal
        flag = 'antipodal';
      else
        flag = '';
      end
      oS = newODFSectionPlot(oCK(1).CS1,oCK(1).CS2,...
        flag,varargin{:});

      ori = oS.makeGrid(varargin{:});
      rgb = oCK.orientation2color(ori);
      
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

