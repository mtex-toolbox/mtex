function varargout = Euler(quat,varargin)
% quaternion to euler angle
%
%% Description
% calculates the Euler angle for a rotation |q|
%
%% Syntax
% [alpha,beta,gamma] = Euler(quat)
% [phi1,Phi,phi2] = Euler(quat,'Bunge')
% euler = Euler(quat,'Bunge')
%
%% Input
%  quat - @quaternion
%% Output
%  alpha, beta, gamma  - Matthies
%  phi1, Phi, phi2     - BUNGE
%% Options
%  ABG, ZYZ   - Matthies (alpha,beta,gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi, Phi, phi2) convention
%% See also
% quaternion/quat2rodrigues

if check_option(varargin,{'nfft','ZYZ','ABG'})
  alpha = atan2(quat.c .* quat.d - quat.a .* quat.b,...
    quat.b .* quat.d + quat.a .* quat.c);
  beta = acos(max(-1,min(1,-quat.b.^2 - quat.c.^2 + quat.d.^2 + quat.a.^2)));
  gamma = atan2(quat.c .* quat.d + quat.a .* quat.b,...
    -quat.b .* quat.d + quat.a .* quat.c);
    labels = {'alpha','beta','gamma'};
else
  gamma = atan2(quat.b .* quat.d - quat.a .* quat.c,...
    quat.c .* quat.d + quat.a .* quat.b);
  beta = acos(max(-1,min(1,-quat.b.^2 - quat.c.^2 + quat.d.^2 + quat.a.^2)));
  alpha = atan2(quat.b .* quat.d + quat.a .* quat.c,...
    -quat.c .* quat.d + quat.a .* quat.b);
  labels = {'phi1','Phi','phi2'};
end

% if rotational axis equal to z
ind = isnull(quat.b) & isnull(quat.c);
alpha(ind) = 2*asin(max(-1,min(1,ssign(quat.a(ind)).*quat.d(ind))));
beta(ind) = 0;
gamma(ind) = 0;


if nargout == 0
  
  disp(' ');
  disp('Euler angle in degree')
  disp(' ');
  disp([labels{1} ' = ']);
  disp(alpha/degree);
  disp([labels{2} ' = ']);
  disp(beta/degree);
  disp([labels{3} ' = ']);
  disp(gamma/degree);
  
elseif check_option(varargin,'nfft')
  
  alpha = fft_rho(alpha);
  beta  = fft_theta(-beta);
  gamma = fft_rho(gamma);
  varargout{1} = 2*pi*[alpha(:),beta(:),gamma(:)].';
  
elseif nargout == 1
  
  varargout{1} = [alpha(:),beta(:),gamma(:)];
  
else
  
  varargout{1} = alpha;
  varargout{2} = beta;
  varargout{3} = gamma;
  
end

return

s = size(quat);
quat = reshape(quat,1,[]);

if check_option(varargin,'BUNGE')
	v = rotate(zvector,quat); 
	beta = real(acos(getz(v)));
	alpha = atan2(gety(v),getx(v)) + pi/2;   
	q = axis2quat(xvector,-beta) .* axis2quat(zvector,-alpha) .* quat;
	gamma = angle(q);
	% if rotational axis equal to -z
  ind = [q.a] .* [q.d] <= 0;
	gamma(ind) = - gamma(ind);
else
	v = rotate(zvector,quat); 
	beta = real(acos(getz(v)));
	alpha = atan2(gety(v),getx(v));
	q = axis2quat(yvector,-beta) .* axis2quat(zvector,-alpha) .* quat;
	gamma = angle(q);
	% if rotational axis equal to -z
  ind = [q.a] .* [q.d] <= 0;
	gamma(ind) = - gamma(ind);
end
alpha = reshape(alpha,s);
beta = reshape(beta,s);
gamma = reshape(gamma,s);

function y = ssign(x)

y = ones(size(x));
y(x<0) = -1;
