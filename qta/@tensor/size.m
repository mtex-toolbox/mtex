function s = size(v,varargin)
% overloads size

s = size(v.x,varargin{:});
