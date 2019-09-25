function I = Mv(solver,c,i)
% forward operator
%
% Input
%  solver - Solver
%  c - coefficients
%  i - intensities
%

% compute Fourier coefficients
c_ext = c(:) * solver.refl{i};
nfsftmex('set_f', solver.nfft_gh(i), c_ext(:));
nfsftmex('adjoint', solver.nfft_gh(i));
fhat = nfsftmex('get_f_hat_linear', solver.nfft_gh(i));

% convolution with kernel function
fhat = 4*pi * fhat .* solver.A;

% evaluate Fourier series at pole figure points r
nfsftmex('set_f_hat_linear', solver.nfft_r(i), fhat);
nfsftmex('trafo', solver.nfft_r(i));
I = real(nfsftmex('get_f', solver.nfft_r(i)));

% sum up specimen symmetry
I = mean(reshape(I,[],length(solver.pf,i)),1).';
  
end  
