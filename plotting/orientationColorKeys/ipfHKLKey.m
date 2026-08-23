classdef ipfHKLKey < ipfColorKey
  % converts orientations to rgb values as HKL Channel 5 does
  %
  % Syntax
  %   oM = ipfHKLKey(cs)
  %   oM = ipfHKLKey(ebsd('phaseName'))
  %   rgb = oM.orientation2color(ori)
  %
  % Input
  %  cs   - @crystalSymmetry
  %  ebsd - @EBSD
  %  ori  - @orientation
  %
  % Output
  %  oM  - @ipfHKLKey
  %  rgb - list of RGB triplets
  %
  % Class Properties
  %  ipfDirection - the specimen direction the inverse pole figure is of
  %  dirMap       - the @HKLDirectionKey doing the coloring
  %
  % See also
  % ipfColorKey HKLDirectionKey ipfTSLKey
  %
    
  methods
    function oM = ipfHKLKey(varargin)
      oM = oM@ipfColorKey(varargin{:});      
      oM.CS1 = oM.CS1.Laue;
      
      oM.dirMap = HKLDirectionKey(oM.CS1);
    end
        
  end  
end
