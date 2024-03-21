function c = curl(SO3VF,varargin)
% curl/rotor of an SO3VectorField
%
% Syntax
%   C = SO3VF.curl % compute the curl
%   c = SO3VF.curl(rot) % evaluate the curl in rot
%
% Input
%  SO3VF - @SO3VectorField
%  rot  - @rotation / @orientation
%
% Output
%  C - @SO3VectorFieldHandle
%  c - @vector3d curl of |SO3VF| at rotation |rot|
%
% See also
% SO3VectorFieldHarmonic/curl SO3VectorField/div SO3Fun/grad


% if SO3VF.tangentSpace.isRight
%   SO3VFl = left(SO3VF);
%   c = curl(SO3VFl,varargin{:});
%   if nargin == 1 || ~isa(varargin{1},'rotation')  
%     c = right(c);
%   else
%     c = right(c,varargin{1});
%   end
%   return
% end

% maybe we should return a function handle
if nargin == 1 || ~isa(varargin{1},'rotation')  
  c = SO3VectorFieldHandle(@(rot) SO3VF.curl(rot,varargin{:}),SO3VF.CS,SO3VF.SS,SO3VF.tangentSpace);
  return
end

rot = varargin{1};
varargin(1) = [];

delta = get_option(varargin,'delta',0.05*degree);
deltaRot = rotation.byAxisAngle([xvector,yvector,zvector],delta/2);

if SO3VF.tangentSpace.isRight
  f = reshape(SO3VF.eval([rot*inv(deltaRot),rot*deltaRot]),length(rot),[]);
else
  f = reshape(SO3VF.eval([inv(deltaRot).*rot,deltaRot.*rot]),length(rot),[]);
end

dx = ( f(:,6).y-f(:,3).y - (f(:,5).z-f(:,2).z) ) ./ delta;
dy = ( f(:,4).z-f(:,1).z - (f(:,6).x-f(:,3).x) ) ./ delta;
dz = ( f(:,5).x-f(:,2).x - (f(:,4).y-f(:,1).y) ) ./ delta;

if SO3VF.tangentSpace.isRight
  c = SO3TangentVector(dx,dy,dz,SO3VF.tangentSpace) + SO3VF.eval(rot);
else
  c = SO3TangentVector(dx,dy,dz,SO3VF.tangentSpace) - SO3VF.eval(rot);
end

end

