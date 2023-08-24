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


if isa(y,'SO3TangentVector') 
  tS = y.tangentSpace;
else
  tS = 'left';
  warning(['The given vector3d values v are assumed to describe elements w.r.t. ' ...
           'the left side tangent space. If you want them to be right sided ' ...
           'use SO3TangentVector(v,''right'') instead.'])
end

if isa(values,'orientation')
  SRight = values.CS; SLeft = values.SS;
else
  [SRight,SLeft] = extractSym(varargin);
  values = orientation(values,SRight,SLeft);
end
% Do quadrature without specimenSymmetry and set SLeft afterwards
% (if left sided tangent space) clear crystalSymmetry otherwise
if strcmp(tS,'right')
  values.CS = crystalSymmetry;
else
  values.SS = specimenSymmetry;
end

SO3F = SO3FunHarmonic.approximation(nodes(:),values.xyz,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
