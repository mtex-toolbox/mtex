function c = curl(SO3VF,varargin)
% curl/rotor of an SO3VectorFieldHarmonic
%
% Syntax
%   C = SO3VF.curl % compute the curl
%   c = SO3VF.curl(rot) % evaluate the curl in rot
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  rot  - @rotation / @orientation
%
% Output
%  C - @SO3VectorFieldHarmonic
%  c - @vector3d curl of |SO3VF| at rotation |rot|
%
% See also
% SO3VectorField/curl SO3VectorFieldHarmonic/div SO3FunHarmonic/grad


% fallback to generic method
if check_option(varargin,'check')
  c = curl@SO3VectorField(SO3VF,varargin{:});
  return
end

Gx = SO3VF.x.grad(SO3VF.internTangentSpace);
Gy = SO3VF.y.grad(SO3VF.internTangentSpace);
Gz = SO3VF.z.grad(SO3VF.internTangentSpace);

c = SO3VectorFieldHarmonic([Gy.z-Gz.y;Gz.x-Gx.z;Gx.y-Gy.x],...
  SO3VF.CS,SO3VF.SS,SO3VF.internTangentSpace);
c.tangentSpace = SO3VF.tangentSpace;

if SO3VF.internTangentSpace.isRight
  c = c + SO3VF;
else
  c = c - SO3VF;
end

n = sqrt(sum(norm(c.SO3F).^2));
if n<1e-4
  c.bandwidth = 0;
end

if nargin > 1 && isa(varargin{1},'rotation')
  ori = varargin{1};
  c = c.eval(ori);
end
