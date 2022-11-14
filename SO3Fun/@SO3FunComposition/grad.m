function g = grad(SO3F,varargin)
% gradient of odf at orientation ori
%
% Syntax
%
%   g = SO3F.grad(ori) % compute the gradient
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(ori,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3FunComposition
%  ori - @orientation
%
% Output
%  g - @vector3d gradient of the ODF at the orientations ori
%
% See also
% ODF/eval orientation/exp

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
  return

end

% compute the gradient for each component seperately
g = 0;
for i = 1:numel(SO3F.components)
  g = g + SO3F.components{i}.grad(varargin{:});
end

end