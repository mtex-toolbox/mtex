function Y = sphericalY(n, v, varargin)
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
% wignerD

[theta,rho] = polar(v);

% try NFSFT version
if check_option(varargin,'nfsft') && n > 0
  
  % precomputation for nfsft
  nfsftmex('precompute',n,1000,1,0);
  plan = nfsftmex('init_advanced',n,length(v),1);

  nfsftmex('set_x',plan,[rho(:).';theta(:).']);
  
  % node-dependent precomputation
  nfsftmex('precompute_x',plan);
  
  Y = zeros(length(v),2*n+1);
  for k = -n:n

    % set Fourier coefficients.
    fhat = zeros((n+1)^2,1);
    fhat(n^2+n+1+k) = 1;
    nfsftmex('set_f_hat_linear',plan,fhat);

    % transform
    nfsftmex('trafo',plan);
  
    % store results
    Y(:,k+n+1) = nfsftmex('get_f',plan);
    %Y = Y((end-2*n):end)';
  end
  nfsftmex('finalize',plan);
  
  return
end

% calculate assoziated legendre functions
L = sqrt(2/(2*n+1))*reshape(legendre(n,cos(theta(:)),'norm').',numel(theta),n+1); % nodes x order

% expand to negative order
if n>0
  L = [fliplr(L(:,2:end)),L];
end

% calcualte spherical harmonics
Y = sqrt((2*n+1)/4/pi) .* L .* exp(1i*rho(:) * (-n:n));

