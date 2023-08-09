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

if nargin>1 && isa(varargin{1},'rotation')
  
  ori = varargin{1};
  if isa(ori,'orientation')
    ensureCompatibleSymmetries(SO3F,ori)
  end
  
  g = vector3d.zeros(size(ori));
  if isempty(ori), return; end

  % compute the gradient for each component seperately
  for i = 1:numel(SO3F.components)
    g = g + SO3F.components{i}.grad(varargin{:});
  end

  if check_option(varargin,'right')
    g.opt.tangentSpace = 'right';
  else
    g.opt.tangentSpace = 'left';
  end

  return

end

% compute the gradient for each component seperately
g = 0;
for i = 1:numel(SO3F.components)
  g = g + SO3F.components{i}.grad(varargin{:});
end
if check_option(varargin,'right')
  g.tangentSpace = 'right';
end

end