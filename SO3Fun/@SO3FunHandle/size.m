function d = size(SO3F,varargin)
% size of @SO3FunHandle

% prevent warning about symmetries by usage of rotation / orientation
warning off
v = SO3F.fun(rotation.id);
warning on

d = size(v);
d = d(2:end);
if isscalar(d), d = [d 1]; end
if nargin > 1, d = d(varargin{1}); end

end
