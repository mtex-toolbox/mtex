function [alpha,beta,gamma] = quat2euler(quat,varargin)
% quaternion to euler angle
%
%% Description
% calculates the Euler angle for a rotation |q|
%
%% Syntax
% [alpha,beta,gamma] = quat2euler(quat)
% [phi1,Phi,phi2] = quat2euler(quat,'Bunge')
%
%% Input
%  quat - @quaternion
%% Output
%  alpha, beta, gamma  - Matthies
%  phi1, Phi, phi2     - BUNGE
%% Options
%  ABG   - Matthies (alpha,beta,gamma) convention (default)
%  BUNGE - Bunge (phi, Phi, phi2) convention
%% See also
% quaternion/quat2rodriguez

if check_option(varargin,'BUNGE')
  alpha = atan2(quat.b .* quat.d - quat.a .* quat.c,...
    quat.c .* quat.d + quat.a .* quat.b);
  beta = acos(-quat.b.^2 - quat.c.^2 + quat.d.^2 + quat.a.^2);
  gamma = atan2(quat.b .* quat.d + quat.a .* quat.c,...
    -quat.c .* quat.d + quat.a .* quat.b);
else
  alpha = atan2(quat.c .* quat.d - quat.a .* quat.b,...
    quat.b .* quat.d + quat.a .* quat.c);
  beta = acos(-quat.b.^2 - quat.c.^2 + quat.d.^2 + quat.a.^2);
  gamma = atan2(quat.c .* quat.d + quat.a .* quat.b,...
    -quat.b .* quat.d + quat.a .* quat.c);
end

% if rotational axis equal to z
ind = isnull(alpha) & isnull(beta) & isnull(gamma);
alpha(ind) = 2*asin(quat.d(ind));
  
return

s = size(quat);
quat = reshape(quat,1,[]);

if check_option(varargin,'BUNGE')
	v = rotate(zvector,quat); 
	beta = real(acos(getz(v)));
	alpha = atan2(gety(v),getx(v)) + pi/2;   
	q = axis2quat(xvector,-beta) .* axis2quat(zvector,-alpha) .* quat;
	gamma = rotangle(q);
	% if rotational axis equal to -z
  ind = [q.a] .* [q.d] <= 0;
	gamma(ind) = - gamma(ind);
else
	v = rotate(zvector,quat); 
	beta = real(acos(getz(v)));
	alpha = atan2(gety(v),getx(v));
	q = axis2quat(yvector,-beta) .* axis2quat(zvector,-alpha) .* quat;
	gamma = rotangle(q);
	% if rotational axis equal to -z
  ind = [q.a] .* [q.d] <= 0;
	gamma(ind) = - gamma(ind);
end
alpha = reshape(alpha,s);
beta = reshape(beta,s);
gamma = reshape(gamma,s);
