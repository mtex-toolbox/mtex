function s = vertcat(varargin)
% overloads [v1;v2;v3..]

s = varargin{1};

cell = cellfun(@(S2G) reshape(vector3d(S2G),[],1),varargin,'uniformoutput',false);

s.vector3d = vertcat(cell{:});

s.res = min(cellfun(@(S2G) S2G.res,varargin));
s.options = delete_option(s.options,'indexed');
