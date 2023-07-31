function f = eval(SO3VF,rot,varargin)
%
% syntax
%   f = eval(SO3VF,rot)
%
% Input
%   rot - @rotation
%
% Output
%   f - @vector3d
%

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3VF,rot)
% end

f = vector3d(SO3VF.SO3F.eval(rot)');
f = reshape(f',size(rot));

if check_option(varargin,'right')
  f = inv(rot).*f;
end

end
