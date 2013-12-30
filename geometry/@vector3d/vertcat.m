function v = vertcat(varargin)
% overloads [v1,v2,v3..]

v = cat(1,varargin{:});
