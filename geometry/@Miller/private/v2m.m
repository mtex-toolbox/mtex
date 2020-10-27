function hkl = v2m(m,varargin)
% vector3d --> Miller-indece 
%
% Syntax
%  v = v2m(m)
%
% Input
%  v - @vector3d
%
% Output
%  h,k,l - integer

% set up matrix
a = m.CS.axes;

%volume
V  = dot(a(1),cross(a(2),a(3)));

a_star = cross(a(2),a(3))./V;
b_star = cross(a(3),a(1))./V;
c_star = cross(a(1),a(2))./V;

[x,y,z] = double([a_star b_star c_star]);
M = [x;y;z];

% compute Miller indice
v = reshape(double(m),[],3).';

hkl = (M \ v)';

if m.lattice.isTriHex
  hkl = [hkl(:,1:2),-hkl(:,1)-hkl(:,2),hkl(:,3)];
end
