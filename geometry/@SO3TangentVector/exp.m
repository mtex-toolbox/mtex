function rot = exp(v,varargin)
% tangent vector to rotation
%
% Syntax
%   rot = exp(v)  % orientation update
%
% Input
%  v - @SO3TangentVector rotation vector in specimen coordinates
%
% Output
%  rot  - @rotation
%
% See also
% vector3d/exp orientation/log

if nargin>1 && isa(varargin{1},'quaternion') 
 r1 = v.oriRef;
 r2 = orientation(varargin{1},r1.CS,r1.SS);
 if r1 ~= r2
   error('The tangent space representation and the given rotations do not coincide.')
 end
end
tS = SO3TangentSpace.extract(varargin,v.tangentSpace);
v = transformTangentSpace(v,tS);

rot_ref = v.oriRef;

rot = exp@vector3d(v,rot_ref,tS);

end