function e = vertcat(varargin)
% overloads [e1;e2;e3..]

e = cat(1,varargin{:});
