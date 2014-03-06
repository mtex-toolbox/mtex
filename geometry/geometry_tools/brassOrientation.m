function o = brassOrientation(cs,varargin)
% returns the cube orientation

o = orientation('Miller',[1 6 8],[2 1 1],cs,varargin{:});
