function d = size(sF,varargin)
% size of @S1FunHandle

v = sF.fun(0);

d = size(v);
d = d(2:end);
if isscalar(d), d = [d 1]; end
if nargin > 1, d = d(varargin{1}); end

end
