function s = size(ebsd,varargin)
% overloads size

s = size(ebsd.rotations,varargin{:});
