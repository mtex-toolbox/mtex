function R = RegMatrix(kk,S3G,varargin)
% regularisation matrix given kernel, grid and order of Sobolev space

% calculate distmatrix for S3G
if check_option(varargin,'EXACT')
  epsilon = pi;
else 
  epsilon = get_option(varargin,'EPSILON',gethw(kk)*4);
end
dMatrix = distmatrix(S3G,[],epsilon);

% calculate Fourier coefficients
%order = get_option(varargin,'ORDER',2); TODO
A = kk.A.^2 .* (2*(0:length(kk.A)-1)+1).^2;
A(1) = 0;

% calculate interpolation points
omega = linspace(0,epsilon,20);
Romega = ClenshawU(A,omega);

% interpolate
interpf = @(dM) interp1(cos(omega/2),Romega,dM);
R = spfun(interpf,dMatrix);
