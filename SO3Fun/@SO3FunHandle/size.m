function d = size(SO3F,varargin)
% size of @SO3FunHandle

d = size(SO3F.fun(orientation.id(SO3F.CS,SO3F.SS)));
d = d(2:end);
if length(d) == 1, d = [d 1]; end
if nargin > 1, d = d(varargin{1}); end

end
