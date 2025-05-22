function f = eval(SO3VF,ori,varargin)
% evaluate the SO3VectorFieldHandle in rotations
% 
% Syntax
%   f = eval(SO3VF,rot)         % left tangent vector
%
% Input
%   rot - @rotation
%
% Output
%   f - @SO3TangentVector
%
% See also
%

% if isa(ori,'orientation')
% ensureCompatibleSymmetries(SO3VF,ori)
% end

f = SO3VF.fun(ori);

f = reshape(SO3TangentVector(f.',SO3TangentSpace.leftVector),size(ori));

tS = SO3TangentSpace.extract(varargin{:},SO3VF.tangentSpace);

f = f.transformTangentSpace(tS,ori);


end