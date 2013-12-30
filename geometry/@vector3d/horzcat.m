function v = horzcat(varargin)
% overloads [v1,v2,v3..]

v = cat(2,varargin{:});
