function ori = byMiller(hkl,uvw,varargin)
% define orientations by Miller Bravais indeces
%
% Description
% Defines an <orientation.orientation.html orientation> |ori|
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
% orientation/orientation orientation/byEuler orientation/byAxisAngle


if isa(hkl,'double')
  if size(hkl,2) == 4
    hkl = {hkl(:,1),hkl(:,2),hkl(:,3),hkl(:,4)};
  else
    hkl = {hkl(:,1),hkl(:,2),hkl(:,3)};
  end
  
  if size(uvw,2) == 4
    uvw = {uvw(:,1),uvw(:,2),uvw(:,3),uvw(:,4)};
  else
    uvw = {uvw(:,1),uvw(:,2),uvw(:,3)};
  end
end

if iscell(hkl)
  CS = getClass(varargin,'crystalSymmetry',crystalSymmetry('cubic'));
  
  hkl = Miller(hkl{:},CS);
  uvw = Miller(uvw{:},CS,'uvw');
  
else
  CS = hkl.CS;
end

SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);

hkl = normalize(hkl(:));
uvw = normalize(uvw);

% ensure angle (v1,v2) = 90°
hkl = vector3d(hkl);
uvw = symmetrise(uvw).';


[err,id] = min(abs(90 - angle(uvw,hkl(:),'noSymmetry')./degree),[],2);
uvw = uvw(sub2ind(size(uvw),(1:size(uvw,1)).',id));

if err > 1*degree
  warning(['Miller indece are not orthogonal. Maximum deviation is ' xnum2str(max(err)) ' degree']);
end

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
ori = orientation(quat,CS,SS);
