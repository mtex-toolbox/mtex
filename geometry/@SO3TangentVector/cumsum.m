function c = cumsum(v,varargin)
% cumulative sum of SO3TangentVector's
%
% Syntax
%   cumsum(v)   % sum along the first non singular dimension
%   cumsum(v,d) % sum along dimension d
%
% Input
%  v - @SO3TangentVector 
%
% Output
%  v - @SO3TangentVector

c = cumsum@vector3d(v,varargin{:});

% ensure compatible tangent spaces
dim = 1;
if nargin>1 && isnumeric(varargin{1})
  dim = varargin{1};
end
s = size(c);
idx = repmat({':'}, 1, length(s));
idx{dim} = 1;
v = c.subSet(idx{:});
ensureCompatibleTangentSpaces(v,c,'equal');

end