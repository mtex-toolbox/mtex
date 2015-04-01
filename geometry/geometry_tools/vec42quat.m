function q = vec42quat(u1,v1,u2,v2)
% returns a quaternion q with q u_1 = v1 and q u2 = v2
%
% Description
% The method *vec42quat* defines a [[quaternion_index.html,quaternion]] |q|
% by 4 directions |u1|, |u2|, |v1| and |v2| such that |q * u1 = v1| and |q
% * u2 = v2| 
%
% Input
%  u1, u2 - @vector3d
%  v1, v2 - @vector3d
%
% Output
%  q - @quaternion
%
% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% euler2quat hr2quat idquaternion 


u1 = vector3d(u1); v1 = vector3d(v1);

% ckeck whether points have the same angle relative to each other
if any(abs(dot(u1,vector3d(u2))-dot(v1,vector3d(v2)))>1E-3)
  
  if isa(u2,'Miller'), u2 = u2.CS * u2; end
  if isa(v2,'Miller'), v2 = v2.CS * v2; end
  
  delta = abs(repmat(angle(u1,u2),1,length(v2)) ...
    - repmat(angle(v1,v2),1,size(u2,1)).');
  [i,j] = find(delta<1*degree,1);
  
  if isempty(i)
    warning(['Inconsitent pairs of vectors!',...
      ' Angle difference: ',num2str(min(delta)),mtexdegchar]) %#ok<WNTAG>
  else
    u2 = u2(i);
    v2 = v2(j);    
  end
end

% normalize input
u1 = normalize(vector3d(u1));
v1 = normalize(vector3d(v1));
u2 = normalize(vector3d(u2));
v2 = normalize(vector3d(v2));

% check vectors are not colinear
if any(abs(dot(u1,u2))>1-eps)
  warning('Input vectors should not be colinear!');
end

% a third orthogonal vector
u3 = normalize(cross(u1,u2));
v3 = normalize(cross(v1,v2));

% make also the second vector orthogonal to the first one
u2t = normalize(cross(u3,u1));
v2t = normalize(cross(v3,v1));

% define the transformation matrix
M = squeeze(double([v1,v2t,v3])).' * squeeze(double([u1,u2t,u3]));

% convert to quaternion
q = mat2quat(M);

return

% old algorithm which has a bug with

u1 = vector3d(0.985371,0.168621,-0.0247103);
v1 = xvector;
u2 = vector3d(-0.159403,0.96321,0.216374);
v2 = yvector;
q1 = vec42quat(u1,v1,u2,v2)
q1*u1
q1*u2

% ckeck whether points have the same angle relative to each other
if any(abs(dot(u1,u2)-dot(v1,v2))>1E-3)
  warning(['Inconsitent pairs of vectors encounterd!',...
    ' Maximum distorsion: ',...
    num2str(max(abs(acos(dot(u1,u2))-acos(dot(v1,v2))))/degree),mtexdegchar]) %#ok<WNTAG>
end

q = repmat(idquaternion,size(u1));

d1 = u1 - v1;
d2 = u2 - v2;

% case 1: u1 = v1 & u2 = v2
% -> nothing has to be done, see initialisation
indLeft = ~(abs(d1)<1e-6 & abs(d2)<1e-6);


% case 2: u1 == v1 -> rotation about u1
ind = indLeft & abs(d1)<1e-6;
indLeft = indLeft & ~ind;

% make orthogonal to u1
pu2 = u2(ind) - dot(u2(ind),u1(ind)).*u1(ind);
pv2 = v2(ind) - dot(v2(ind),v1(ind)).*v1(ind);
% compute angle
omega = acos(dot(pu2,pv2));

% compute axis
a = cross(pu2,pv2);
a = a ./ norm(a);

% the above axi can be zero for 180 degree rotations -> then u1 is ok
a = 2*a + u1;
a = a ./ norm(a);

% define rotation
q(ind) = axis2quat(a,omega);


% case 3: u2 == v2 -> rotation about u2
ind = indLeft & abs(d2)<1e-6;
indLeft = indLeft & ~ind;

% make orthogonal to u2
pu1 = u1(ind) - dot(u1(ind),u2(ind)).*u2(ind);
pv1 = v1(ind) - dot(v1(ind),v2(ind)).*v2(ind);
% compute angle
omega = acos(dot(pu1,pv1));

% compute axis
a = cross(pu1,pv1);
a = a ./ norm(a);

% the above axi can be zero for 180 degree rotations -> then u2 is ok
a = 2*a + u2;
a = a ./ norm(a);

% define rotation
q(ind) = axis2quat(a,omega);


% case 4: u1 = +- u2 -> rotation about u1 x v1

ind = indLeft & (abs(u1+u2)<1e-6 | abs(u1-u2)<1e-6);
indLeft = indLeft & ~ind;

% compute axis
ax = cross(u1(ind),v1(ind));
ax = ax./norm(ax);

% compute angle
omega = acos(dot(u1(ind),v1(ind)));

% define rotation
if isempty(omega), omega =[];end
q(ind) = axis2quat(ax,omega);


% case 5: d1 || d2 and rotation about 180 degree
ind = indLeft & abs(cross(d1,d2))<1e-6 & ...
  abs(cross(cross(u1,u2),cross(v1,v2))) < 1e-6;
indLeft = indLeft & ~ind;

ax = (u1(ind)+v1(ind)) + 100*(u2(ind)+v2(ind));
ax = ax./norm(ax);

q(ind) = axis2quat(ax,pi);


% case 6: d1 || d2 -> rotation about (u1 x u2) x (v1 x v2)
ind = indLeft & abs(cross(d1,d2))<1e-6 ;
indLeft = indLeft & ~ind;

ax = cross(cross(u1(ind),u2(ind)),cross(v1(ind),v2(ind)));
ax = ax./norm(ax);

a = cross(ax,v1(ind));
a = a ./ norm(a);

b = cross(ax,u1(ind));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(ind) = axis2quat(ax,omega);


% case 7: d1 and d2 are not collinear -> rotation about d1 x d2

% roation axis
axis = cross(d1(indLeft),d2(indLeft));
axis = axis ./ norm(axis);

% compute angle
a = cross(axis,v1(indLeft));
a = a ./ norm(a);

b = cross(axis,u1(indLeft));
b = b ./ norm(b);

omega = acos(dot(a,b));

q(indLeft) = axis2quat(axis,omega);


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
% u1 = vector3d('polar',(90-52.403)*degree,86.08*degree);
% v1 = vector3d('polar',(90-52.422)*degree,-0.422*degree);
% u2 = vector3d('polar',(90-53.327)*degree,47.396*degree);
% v2 = vector3d('polar',(90-28.795)*degree,-14.590*degree);

%u1 = vector3d('polar',(90-64.063)*degree,76.128*degree);
%v1 = vector3d('polar',(90-40.128)*degree,-20.725*degree);
%u2 = vector3d('polar',(90-46.812)*degree,46.977*degree);
%v2 = vector3d('polar',(90-39.573)*degree,0.773*degree);
%

% q = rotation('Euler',20*degree,10*degree,50*degree);
% u1 = xvector;
% u2 = yvector;

% q = rotation('axis',zvector,'angle',20*degree)
% qq = rotation('map',u1,q*u1,u2,q*u2)
