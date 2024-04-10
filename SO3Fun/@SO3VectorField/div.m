function d = div(SO3VF,varargin)
% divergence of an SO3VectorField
%
% Syntax
%   D = SO3VF.div % compute the divergence
%   d = SO3VF.div(rot) % evaluate the divergence in rot
%
% Input
%  SO3VF - @SO3VectorField
%  rot  - @rotation / @orientation
%
% Output
%  D - @SO3Fun
%  d - @double divergence of |SO3VF| at rotation |rot|
%
% See also
% SO3VectorFieldHarmonic.div SO3Fun.grad SO3Fun.curl 

% maybe we should return a function handle
if nargin == 1 || ~isa(varargin{1},'rotation')  
  d = SO3FunHandle(@(rot) SO3VF.div(rot,varargin{:}),SO3VF.CS,SO3VF.SS);
  return
end

rot = varargin{1};
varargin(1) = [];

delta = get_option(varargin,'delta',0.05*degree);

deltaRot = rotation.byAxisAngle([xvector,yvector,zvector],delta/2);

if SO3VF.tangentSpace.isRight
  f = reshape(SO3VF.eval([rot*inv(deltaRot),rot*deltaRot]),length(rot),[]);
else
  f = reshape(SO3VF.eval([inv(deltaRot).*rot,deltaRot.*rot]),length(rot),[]);
end


d = (f(:,4).x-f(:,1).x+f(:,5).y-f(:,2).y+f(:,6).z-f(:,3).z) ./ delta;

end

function TestDivergence

r = rotation.rand;

f1 = SO3FunHarmonic.WignerDmap(5,2,-3);
f1.isReal=true;
F1 = f1.grad;
d1 = div(F1);
d1.eval(r)/f1.eval(r)

f2 = SO3FunHandle(@(r) f1.eval(r));
F2 = f2.grad;
d2 = div(F2);
d2.eval(r)/f2.eval(r)

end