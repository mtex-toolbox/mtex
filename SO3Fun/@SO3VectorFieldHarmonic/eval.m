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

if check_option(varargin,'right')
  % make left sided to right sided tangent vectors
  f = inv(rot).*f;
  f = SO3TangentVector(f,'right');
else
  f = SO3TangentVector(f,'left');
end

end
