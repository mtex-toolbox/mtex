function f = eval(SO3VF,rot,varargin)
% evaluate the SO3VectorFieldHarmonic in rotations
% 
% syntax
%   f = eval(SO3VF,rot)         % left tangent vector
%   f = eval(SO3VF,rot,'right') % right tangent vector
%
% Input
%   rot - @rotation
%
% Output
%   f - @vector3d
%

% change evaluation method to quadratureSO3Grid/eval
if isa(rot,'quadratureSO3Grid')
  f = eval(SO3VF,rot,varargin);
else
  % if isa(rot,'orientation')
  %   ensureCompatibleSymmetries(SO3VF,rot)
  % end
  f = vector3d(SO3VF.SO3F.eval(rot)');
  f = reshape(f',size(rot));
end

% Make output right/left deendent from the input flag
f = SO3TangentVector(f,SO3VF.tangentSpace);
if check_option(varargin,'right')
  f = right(f,rot);
end
if check_option(varargin,'left')
  f = left(f,rot);
end



end
