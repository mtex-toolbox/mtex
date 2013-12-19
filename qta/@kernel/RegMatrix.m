function R = RegMatrix(kk,S3G,varargin)
% regularisation matrix given kernel, grid and order of Sobolev space
%
%% Input
%
%% Output

if check_option(varargin,'EXACT')
  epsilon = pi;
else 
  epsilon = get_option(varargin,'EPSILON',gethw(kk)*4);
end

% calculate Fourier coefficients
%order = get_option(varargin,'ORDER',2); TODO
A = kk.A.^2 .* (2*(0:length(kk.A)-1)+1).^2;
A(1) = 0;

% calculate interpolation points
omega = linspace(0,epsilon,20);
Romega = ClenshawU(A,omega);

% interpolate
interpf = @(co2) interp1(omega,Romega,co2);
R = spfun(interpf,dout_outer(S3G,S3G,epsilon));
