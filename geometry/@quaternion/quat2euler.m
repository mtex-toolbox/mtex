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
