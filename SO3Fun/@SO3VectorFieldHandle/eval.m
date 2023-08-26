function f = eval(SO3VF,ori,varargin)
% evaluate the SO3VectorFieldHandle in rotations
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

% if isa(ori,'orientation')
% ensureCompatibleSymmetries(SO3VF,ori)
% end

f = SO3VF.fun(ori);

% Make output right/left dependent from the input flag
f = SO3TangentVector(f,SO3VF.tangentSpace);
if check_option(varargin,'right')
  f = right(f,ori);
end
if check_option(varargin,'left')
  f = left(f,ori);
end

end