function ebsd = rotate_outer(ebsd,rot,varargin)
% rotate EBSD, same as EBSD/rotate 

ebsd = rotate(ebsd,rot,varargin{:});