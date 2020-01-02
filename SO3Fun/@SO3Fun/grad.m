function g = grad(SO3F,varargin)
% gradient of odf at orientation ori
%
% Syntax
%
%   g = SO3F.grad(rot) % compute the gradient
%
%   % go 5 degree in direction of the gradient
%   rot_new = exp(rot,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3Fun
%  rot  - @rotation / @orientation
%
% Output
%  g - @vector3d gradient of |SO3F| at rotation |rot|
%
% See also
%

% maybe we should return a function hand
if nargin == 1 || ~isa(varargin{1},'rotation')  
  g = SO3VectorFieldHandle(@(rot) SO3F.grad(rot,varargin{:}),SO3F.CS,SO3F.SS);
  return
end
  
rot = varargin{1};
varargin(1) = [];

delta = get_option(varargin,'delta',0.05*degree);

deltaRot = rotation.byAxisAngle([xvector,yvector,zvector],delta/2);

%f = component.eval([ori(:),(rot*ori).']);
f = reshape(SO3F.eval([rot*inv(deltaRot),rot*deltaRot]),length(rot),[]);

g = vector3d(f(:,4)-f(:,1),f(:,5)-f(:,2),f(:,6)-f(:,3)) ./ delta;
