function q = vec42quat(u1,v1,u2,v2)
% calculate quaternion q with q u_1 = v1 and q u2 = v2
%
%% Description
% The method *vec42quat* defines a [[quaternion_index.html,rotation]] |q|
% by 2 crystal directions |u1| and |u2| and two specimen directions 
% |v1| and |v2| such that |q * u1 = v1| and |q * u2 = v2|
%
%% Input
%  u1, v1 , u2, v2 - @vector3d
%
%% Output
%  q - @quaternion
%
%% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% euler2quat hr2quat idquaternion 


% ckeck whether points have the same angle relative to each other
if any(abs(dot(u1,u2)-dot(v1,v2))>1E-3)
  warning(['Inconsitent pairs of vectors encounterd!',...
    ' Maximum distorsion: ',...
    num2str(max(abs(acos(dot(u1,u2))-acos(dot(v1,v2))))/degree),mtexdegchar])
end

q = repmat(idquaternion,size(u1));

axis = cross(u1 - v1,u2 - v2);

% first case: u1-v1 and u2-v2 are not collinear
ind = ~isnull(axis);

ax = axis(ind) ./ norm(axis(ind));

a = cross(ax,v1(ind));
a = a ./ norm(a);

b = cross(ax,u1(ind));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(ind) = axis2quat(ax,omega);

% second case u1 = -u2

ind2 = ~ind & isnull(u1+u2);

ax = cross(u1(ind2),v1(ind2));
ax = ax./norm(ax);

omega = acos(dot(u1(ind2),v1(ind2)));

q(ind2) = axis2quat(ax,omega);

% third case
ind3 = ~(ind | ind2) & ~isnull(u1-v1);

ax = cross(cross(u1(ind3),u2(ind3)),cross(v1(ind3),v2(ind3)));
ax = ax./norm(ax);

a = cross(ax,v1(ind3));
a = a ./ norm(a);

b = cross(ax,u1(ind3));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(ind3) = axis2quat(ax,omega);

% fourth case
ind4 = ~(ind | ind2 | ind3);

ax = cross(cross(u1(ind4),u2(ind4)),cross(v1(ind4),v2(ind4)));
ax = ax./norm(ax);

a = cross(ax,v2(ind4));
a = a ./ norm(a);

b = cross(ax,u2(ind4));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(ind4) = axis2quat(ax,omega);

% check function:
%
% u1 = xvector;
% u1 = yvector;
% v1 = xvector;
% v1 = yvector;
% u2 = zvector;
% u2 = xxvector;
% v2 = yvector;
%
% q = vec42quat(u1,v1,u2,v2);
%
% [q*u1,q*u2]
% 
%
% u1 = sph2vec((90-52.403)*degree,86.08*degree);
% v1 = sph2vec((90-52.422)*degree,-0.422*degree);
% u2 = sph2vec((90-53.327)*degree,47.396*degree);
% v2 = sph2vec((90-28.795)*degree,-14.590*degree);

u1 = sph2vec((90-64.063)*degree,76.128*degree);
v1 = sph2vec((90-40.128)*degree,-20.725*degree);
u2 = sph2vec((90-46.812)*degree,46.977*degree);
v2 = sph2vec((90-39.573)*degree,0.773*degree);
%
