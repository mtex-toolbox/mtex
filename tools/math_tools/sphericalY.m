function Y = sphericalY(l, theta, rho)
% spherical harmonics of degree l
%
%% Description
% Y = sphericalY(l,theta,rho) return a vector Y = (Y_l^-l,...,Y_l^l) of the
% spherical harmonics of degree l using the Condon-Shortley phase
% convention
%
%% Input
%  l     - degree
%  theta - polar angle
%  rho   - azimuth angle
%
%% Output
%  Y - (2l+1) x numel(theta,rho) matrix of function values
%
%% See also
% wignerD

if isa(theta,'vector3d'), [theta,rho] = polar(theta); end

% calculate assoziated legendre functions
L = reshape(legendre(l,cos(theta(:))).',numel(theta),l+1); % nodes x order

% right normalization
w = sqrt(factorial(l-abs(0:l))./factorial(l+abs(0:l)));
L = L * diag(w);       

% expand to negative order
if l>0
  L = [fliplr(L(:,2:end)),L]*diag((-1).^(-l:l));
end

% calcualte spherical harmonics
Y = sqrt((2*l+1)/4/pi) .* L .* exp(1i*rho(:) * (-l:l));

