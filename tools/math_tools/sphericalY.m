function Y = sphericalY(l, theta, rho,varargin)
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

% try NFSFT version
if check_option(varargin,'nfsft') && l > 0
  
  % precomputation for nfsft
  nfsft_precompute(l,1000);
  plan = nfsft_init_advanced(l,1,NFSFT_NORMALIZED);

  nfsft_set_x(plan,[rho;theta]);
  
  % node-dependent precomputation
  nfsft_precompute_x(plan);
  
  % Set Fourier coefficients.
  nfsft_set_f(plan,1);

  % transform
  nfsft_adjoint(plan);
  
  % store results
  Y = nfsft_get_f_hat_linear(plan);
  Y = Y((end-2*l):end)';
  
  nfsft_finalize(plan);
  
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

