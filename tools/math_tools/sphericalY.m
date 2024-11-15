function Y = sphericalY(l, v, varargin)
% spherical harmonics of degree l
%
% Description
% Y = sphericalY(l,vs) return a vector Y = (Y_l^-l,...,Y_l^l) of the
% spherical harmonics of degree l using the Condon-Shortley phase convention
%
% Syntax
%   Y = sphericalY(l, v)
%
% Input
%  l - harmonic degree
%  v - @vector3d
%
% Output
%  Y - (2l+1) x length(v) matrix of function values
%
% See also
% WignerD

if isa(l,'vector3d')
  vec=v; v = l; l = vec;
end

[theta,rho] = polar(v);

% try NFSFT version
if check_option(varargin,'nfsft') && l > 0
  
  % precomputation for nfsft
  nfsftmex('precompute',l,1000,0,0);
  plan = nfsftmex('init_advanced',l,1,1);

  nfsftmex('set_x',plan,[rho;theta]);
    
  % Set Fourier coefficients.
  nfsftmex('set_f',plan,1);

  % transform
  nfsftmex('adjoint',plan);
  
  % store results
  Y = nfsftmex('get_f_hat_linear',plan);
  Y = Y((end-2*l):end)';
  
  nfsftmex('finalize',plan);
  
  return
end

% calculate assoziated legendre functions
L = sqrt(2/(2*l+1))*reshape(legendre(l,cos(theta(:)),'norm').',numel(theta),l+1); % nodes x order

% expand to negative order
if l>0
  L = [fliplr(L(:,2:end)),L];
end

% calcualte spherical harmonics
Y = sqrt((2*l+1)/4/pi) .* L .* exp(1i*rho(:) * (-l:l));

