function g = grad(SO3F,varargin)
% gradient of an SO3FunComposition
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(rot,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3FunComposition
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorField
%  g - @vector3d gradient of the ODF at the orientations ori
%
% See also
% SO3Fun/eval orientation/exp

% compute the gradient for each component seperately
g = SO3F.components{1}.grad(varargin{:});
for i = 2:numel(SO3F.components)
  g = g + SO3F.components{i}.grad(varargin{:});
end

end