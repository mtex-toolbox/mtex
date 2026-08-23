classdef ipfTSLKey < ipfColorKey
  % converts orientations to rgb values as TSL / OIM does
  %
  % Syntax
  %   oM = ipfTSLKey(cs)
  %   oM = ipfTSLKey(ebsd('phaseName'))
  %   rgb = oM.orientation2color(ori)
  %
  % Input
  %  cs   - @crystalSymmetry
  %  ebsd - @EBSD
  %  ori  - @orientation
  %
  % Output
  %  oM  - @ipfTSLKey
  %  rgb - list of RGB triplets
  %
  % Class Properties
  %  ipfDirection - the specimen direction the inverse pole figure is of
  %  dirMap       - the @TSLDirectionKey doing the coloring
  %
  % See also
  % ipfColorKey TSLDirectionKey ipfHKLKey
  %
      
  methods
    function oM =ipfTSLKey(varargin)

      oM = oM@ipfColorKey(varargin{:}); 
      oM.CS1 = oM.CS1.Laue;
      oM.dirMap = TSLDirectionKey(oM.CS1);
      
    end
  end
    
end
