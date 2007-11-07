function Y = sphericalY(l, theta, rho)
% spherical harmonics of degree l
%
%% Input
%  l     - degree
%  theta - azimuth angle
%  rho   - polar
%
%% Output
%  Y - (2l+1) x numel(theta,rho) matrix of function values
%
%% See also
%

if isa(theta,'vector3d')
  [theta,rho] = vec2sph(theta);
end

% calculate assoziated legendre functions
L = reshape(legendre(l,cos(theta(:))).',numel(theta),l+1); % nodes x order

% right normalization
w = sqrt(factorial(l-abs(0:l))./factorial(l+abs(0:l)));
L = L * diag(w);       

% expand to negative order
if l>0, L = [fliplr(L(:,2:end))*diag((-1).^(-l:-1)),L];end
L = fliplr(L);
%if l>0, L = [fliplr(L(:,2:end)),L];end

% calcualte spherical harmonics
Y = sqrt((2*l+1)/4/pi) .* L .* exp(i*rho(:) * (-l:l));
%Y = fliplr(Y);