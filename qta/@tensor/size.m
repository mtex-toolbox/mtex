function s = size(T,varargin)
% overloads size

s = size(T.M,varargin{:});
