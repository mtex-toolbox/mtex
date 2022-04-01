function d = size(F, varargin)
% size of @SO3FunHarmonic

d = size(F.fhat);
d = d(2:end);
if length(d) == 1, d = [d 1]; end
if nargin > 1, d = d(varargin{1}); end

end
