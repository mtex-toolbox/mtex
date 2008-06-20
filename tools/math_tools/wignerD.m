function D = wignerD(l, alpha,beta,gamma)
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

if isa(alpha,'quaternion')
  g = quat2euler(alpha,'nfft');
else
  alpha = fft_rho(alpha);
  beta  = fft_theta(beta);
  gamma = fft_rho(gamma);
  g = 2*pi*[alpha(:),beta(:),gamma(:)].';
end


c = 1;
L = max(l,3);
A = ones(L+1,1);

global mtex_path;

% run NFSOFT
D = run_linux([mtex_path,'/c/bin/odf2fc'],'EXTERN',g,c,A);
      
% extract result
D = complex(D(1:2:end),D(2:2:end));

D = reshape(D(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);

%D = triu(D) - triu(D,1)';

function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;

