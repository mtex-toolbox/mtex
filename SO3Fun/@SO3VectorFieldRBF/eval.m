function f = eval(SO3VF,rot,varargin)
% evaluate the SO3VectorFieldRBF in rotations
% 
% Syntax
%   f = eval(SO3VF,rot) 
%
% Input
%   rot - @rotation
%
% Output
%   f - @vector3d
%
% See also
% SO3FunRBF/eval


% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3VF,rot)
% end


% check whether the hidden symmetries match the symmetries of the
% underlying SO3Fun dependent on the tangent space representation
check_symmetry(SO3VF)

% evaluation method
xyz = SO3VF.SO3F.eval(rot,varargin{:});

% generate tangent space vector
f = SO3TangentVector(xyz.',rot(:),SO3VF.internTangentSpace,SO3VF.hiddenCS,SO3VF.hiddenSS);
f = reshape(f,size(rot));

% Maybe change tangent space
tS = SO3TangentSpace.extract(varargin{:},SO3VF.tangentSpace);
f = transformTangentSpace(f,tS);

end
