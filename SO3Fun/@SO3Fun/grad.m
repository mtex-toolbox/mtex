function g = grad(SO3F,varargin)
% gradient of an SO3Fun w.r.t. the tangent space basis 
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   rot_new = exp(rot,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3Fun
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorField
%  g - @vector3d gradient of |SO3F| at rotation |rot|
%
% See also
% SO3Fun/eval orientation/exp SO3FunHarmonic/grad SO3FunRBF/grad
% SO3FunCBF/grad SO3VectorField

tS = SO3TangentSpace.extract(varargin{:});

% maybe we should return a function handle
if nargin == 1 || ~isa(varargin{1},'rotation')  
  
  if SO3F.bandwidth < getMTEXpref('maxSO3Bandwidth') && ~check_option(varargin,'check')
    SO3F = SO3FunHarmonic(SO3F);
    g = grad(SO3F,varargin{:});
  else
    g = SO3VectorFieldHandle(@(rot) SO3F.grad(rot,varargin{:}),SO3F.CS,SO3F.SS,varargin{:});
    g.tangentSpace = tS;    
  end
  return
end
  
rot = varargin{1};
s = size(rot);
rot = rot(:);
varargin(1) = [];

delta = get_option(varargin,'delta',0.05*degree);

deltaRot = rotation.byAxisAngle([xvector,yvector,zvector],delta/2);

%f = SO3F.eval([ori(:),(rot*ori).']);
if tS.isRight
  f = reshape(SO3F.eval([rot*inv(deltaRot),rot*deltaRot]),length(rot),[]);
else
  f = reshape(SO3F.eval([inv(deltaRot).*rot,deltaRot.*rot]),length(rot),[]);
end

g = SO3TangentVector(f(:,4)-f(:,1),f(:,5)-f(:,2),f(:,6)-f(:,3),rot,tS,SO3F.CS,SO3F.SS) ./ delta;

g = reshape(g,s);