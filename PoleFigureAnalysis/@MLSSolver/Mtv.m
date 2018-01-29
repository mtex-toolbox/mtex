function d = Mtv(solver,I,i)
% forward operator
%
% Input
%  P
%  alpha
%
% Output
%
%  d
  
% compute Fourier coefficients
nfsftmex('set_f', solver.nfft_r(i), I{i});
nfsftmex('adjoined', solver.nfft_r(i));
fhat = nfsftmex('get_f_hat_linear', solver.nfft_r(i));

% evaluate Fourier series at pole figure points g h_i
nfsftmex('set_f_hat_linear', solver.nfft_gh(i), fhat);
nfsftmex('trafo', solver.nfft_gh(i));
d = reshape(nfsftmex('get_f', solver.nfft_gh(i)),solver.nr(i),[]);

end
