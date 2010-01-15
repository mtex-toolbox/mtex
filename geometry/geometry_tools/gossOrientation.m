function q = gossOrientation(cs,varargin)
% returns the cube orientation

q = orientation('Miller',[0 1 1],[1 0 0],cs,varargin{:});
