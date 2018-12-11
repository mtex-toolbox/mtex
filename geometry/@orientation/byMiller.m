function ori = byMiller(hkl,uvw,varargin)
% define orientations by Miller Bravais indeces
%
% Description
% Defines an <orientation_index.html,orientation> |ori|
% by Miller indece (hkl) and [uvw] such that |ori * (hkl) = 001| and 
% |ori * [uvw] = 100|
%
% Syntax
%   
%   hkl = Miller(h,k,l,CS,'hkl')
%   uvw =  Miller(u,v,w,CS,'uvw')
%   ori = orientation.byMiller(hkl,uvw)
%
%   ori = orientation.byMiller([h k l],[u v w],CS)
%
% Input
%  hkl, uvw - @Miller
%  h,k,l  - Miller indece (double)
%  u,v,w  - Miller indece (double)
%  CS     - @crystalSymmetry
%
% Output
%  ori - @orientation
%
% See also
% orientation_index orientation/byEuler orientation/byAxisAngle


if isa(hkl,'double')
  if nargin == 2
    CS = crystalSymmetry('cubic');
  else
    CS = varargin{1};
  end
  hkl = Miller(hkl(1),hkl(2),hkl(3),CS);
  uvw = Miller(uvw(1),uvw(2),uvw(3),CS);
end

hkl = normalize(hkl);
uvw = normalize(uvw);

% ensure angle (v1,v2) = 90°
hkl = vector3d(hkl);
uvw = symmetrise(uvw);

uvw = uvw(isnull(dot(vector3d(hkl),vector3d(uvw)))); uvw = uvw(1);

if isempty(uvw), error('Miller indece have to be orthogonal');end

% hkl -> e3
q1 = hr2quat(hkl,zvector);

q1v2 = q1 .* uvw;
phi = dot(q1v2,xvector);

% q1uvw -> e1
d = dot(cross(q1v2,xvector),zvector);
q2 = axis2quat(zvector,sign(d).*acos(phi));

% q1v2 ?= e1
ind = isnull(phi - 1);
quat = q1;
quat(~ind) = q2(~ind).*q1(~ind);

% make the result an orientation
ori = orientation(quat,varargin{:});
try ori.CS = hkl.CS; end %#ok<TRYNC>
