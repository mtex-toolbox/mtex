function SO3F = dot(SO3VF1, SO3VF2, varargin)
% pointwise inner product
%
% Syntax
%   SO3F = dot(SO3VF1, SO3VF2)
%
% Input
%   SO3VF1, SO3VF2 - @SO3VectorField
%
% Output
%   SO3F - @SO3FunHarmonic
%

% linear combination of the components
if isa(SO3VF1,'vector3d')
  SO3F = dot(SO3VF2,SO3VF1);
  return
end
if isa(SO3VF2, 'vector3d')
  % Change intern tangent space to outer tangent space
  if sign(SO3VF1.internTangentSpace) ~= sign(SO3VF1.tangentSpace)
    if SO3VF1.internTangentSpace.isLeft
      SO3VF1 = right(SO3VF1,'internTangentSpace');
    else
      SO3VF1 = left(SO3VF1,'internTangentSpace');
    end
  end

  % Compute weighted sum of the 3 SO3Funs
  SO3F = SO3VF1.SO3F;
  v = SO3VF2;
  SO3F = reshape(sum( SO3F .* reshape(v.xyz.',[3,size(v)]),1),size(v));
  if SO3VF2.antipodal
    SO3F = abs(SO3F);
  end
  return
end


% Note that for SO3VF.SO3F = dot(SO3VF1.SO3F,SO3VF2.SO3F) the tangentSpaces 
% and internTangentSpaces have to be the same and we need to know that both
% are harmonic vector fields
SO3F = dot@SO3VectorField(SO3VF1,SO3VF2);

bw = min(getMTEXpref('maxSO3Bandwidth'),SO3VF1.bandwidth + SO3VF2.bandwidth);
SO3F = SO3FunHarmonic(SO3F,'bandwidth', bw, varargin{:});

end