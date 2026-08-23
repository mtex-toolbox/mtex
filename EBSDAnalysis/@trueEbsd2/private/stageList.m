function stages = stageList(T)
% the stages of a hop's transform, as prototypes to be fitted one at a time
%
% A tilt is fitted as a projective, then a polynomial on what it leaves, then
% another - each against a freshly measured residual, which is why the job
% drives the loop and the class only says what the stages are.
%
% Syntax
%
%   stages = stageList(spatialTransformTilt)   % 3 prototypes
%   stages = stageList(spatialTransformId)     % empty - nothing to fit
%
% Input
%  T - @spatialTransform, an unfitted prototype
%
% Output
%  stages - @spatialTransform array, in the order they are fitted
%
% See also
% trueEbsd2/calcDistortion spatialTransform

% NOT isid: an unfitted prototype has zero coefficients and so reports itself
% as the identity. Only spatialTransformId means nothing separates the pair -
% the same class-not-value rule spatialTransform/plus applies.
if isa(T,'spatialTransformId'), stages = spatialTransform.empty; return; end

if isa(T,'spatialTransformTilt') || isa(T,'spatialTransformComposite')
  stages = T.stages;
else
  stages = T;
end

end
