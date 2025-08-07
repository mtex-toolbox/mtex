function f = eval(SO3VF,ori,varargin)
% evaluate the SO3VectorFieldHandle in rotations
% 
% Syntax
%   f = eval(SO3VF,rot)    
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

% generate tangent space vector
if ~isa(f,'SO3TangentVector')
  f = SO3TangentVector(f.',ori(:),SO3VF.internTangentSpace,SO3VF.hiddenCS,SO3VF.hiddenSS);
  f = reshape(f,size(ori));
end

% Maybe change tangent space
tS = SO3TangentSpace.extract(varargin{:},SO3VF.tangentSpace);
f = transformTangentSpace(f,tS);

end