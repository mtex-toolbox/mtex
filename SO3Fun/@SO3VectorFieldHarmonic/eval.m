function f = eval(SO3VF,rot,varargin)
% evaluate the SO3VectorFieldHarmonic in rotations
% 
% Syntax
%   f = eval(SO3VF,rot)         % left tangent vector
%   f = eval(SO3VF,rot,'right') % right tangent vector
%
% Input
%   rot - @rotation
%
% Output
%   f - @vector3d
%
% See also
% 

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3VF,rot)
% end

% change evaluation method to quadratureSO3Grid.eval
if isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis')
  f = evalEquispacedFFT(SO3VF.SO3F,rot,varargin{:});
  f = vector3d(f.');
  f = reshape(f',size(rot));
elseif isa(rot,'quadratureSO3Grid')
  f = quadratureSO3Grid.eval(SO3VF,rot,varargin{:});
else
  f = vector3d(SO3VF.SO3F.eval(rot).');
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
