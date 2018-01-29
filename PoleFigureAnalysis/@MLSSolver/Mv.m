function I = Mv(solver,c,i)
% forward operator
%
% Input
%  c - coefficients
%  alpha - 
%
% Input
%   alpha
%   c
%   nfft_plan

% compute Fourier coefficients
nfsftmex('set_f', solver.nfft_gh(i), c);
nfsftmex('adjoint', solver.nfft_gh(i));
fhat = nfsftmex('get_f_hat_linear', solver.nfft_gh(i));

% evaluate Fourier series at pole figure points r
nfsftmex('set_f_hat_linear', solver.nfft_r(i), fhat);
nfsftmex('trafo', solver.nfft_r(i));
I = nfsftmex('get_f', solver.nfft_r(i));
  
end  
