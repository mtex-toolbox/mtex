function d = Mtv(solver,I,i)
% forward operator
%
% Input
%  I
%  alpha
%
% Output
%
%  d
  
% extend specimen symmetry
lss = length(solver.SS.properGroup);
I_ext = repmat(I.',lss,1)./lss;

% compute Fourier coefficients
nfsftmex('set_f', solver.nfft_r(i), I_ext);
nfsftmex('adjoint', solver.nfft_r(i));
fhat = nfsftmex('get_f_hat_linear', solver.nfft_r(i));

% convolution with kernel function
fhat = 4*pi*fhat .* solver.A;

% evaluate Fourier series at pole figure points g h_i
nfsftmex('set_f_hat_linear', solver.nfft_gh(i), fhat);
nfsftmex('trafo', solver.nfft_gh(i));
d = real(nfsftmex('get_f', solver.nfft_gh(i)));
d = reshape(d,length(solver.c),[]) * solver.refl{i}.';

end
