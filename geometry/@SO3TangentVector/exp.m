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
 r1 = orientation(v.rot,v.hiddenCS,v.hiddenSS);
 r2 = orientation(varargin{1},v.hiddenCS,v.hiddenSS);
 if r1 ~= r2
   error('The tangent space representation and the given rotations do not coincide.')
 end
end
tS = SO3TangentSpace.extract(varargin,v.tangentSpace);
v = transformTangentSpace(v,tS);

rot_ref = orientation(v.rot,v.hiddenCS,v.hiddenSS);

rot = exp@vector3d(v,rot_ref,tS);

end