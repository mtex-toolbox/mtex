function SO3VF = approximation(nodes, values, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.approximation(nodes, values)
%   SO3VF = SO3VectorFieldHarmonic.approximation(nodes, values, 'bandwidth', bw)
%
% Input
%   nodes - @rotation
%   values - @vector3d
%
% Output
%   SO3VF - @SO3VectorFieldHarmonic
%
% Options
%   bandwidth - maximal degree of the Wigner-D functions (default: 128)
%
% See also
% SO3FunHarmonic/approximation SO3VectorFieldHarmonic


if isa(values,'SO3TangentVector') 
  tS = values.tangentSpace;
else
  tS = SO3TangentSpace.leftVector;
  warning(['The given vector3d values v are assumed to describe elements w.r.t. ' ...
           'the left side tangent space. If you want them to be right sided ' ...
           'use SO3TangentVector(v,SO3TangentSpace.rightVector) instead.'])
end

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end
% Do quadrature without specimenSymmetry and set SLeft afterwards
% (if left sided tangent space) clear crystalSymmetry otherwise
if tS.isRight
  nodes.CS = crystalSymmetry;
else
  nodes.SS = specimenSymmetry;
end

SO3F = SO3FunHarmonic.approximation(nodes(:),values.xyz,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
