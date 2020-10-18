function e = horzcat(varargin)
% overloads [e1,e2,e3..]

e = cat(2,varargin{:});
