function f = eval(SO3VF,rot,varargin)
% evaluate the SO3VectorFieldRBF in rotations
% 
% Syntax
%   f = eval(SO3VF,rot)         % left tangent vector
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

xyz = SO3VF.SO3F.eval(rot);

% generate tangentspace vector
f = SO3TangentVector(xyz.',rot(:),SO3VF.internTangentSpace);
f = reshape(f,size(rot));

tS = SO3TangentSpace.extract(varargin{:},SO3VF.tangentSpace);

f = transformTangentSpace(f,tS);

end
