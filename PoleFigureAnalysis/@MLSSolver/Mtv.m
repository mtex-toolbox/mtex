function d = Mtv(solver,I,ind)
% adjoined forward operator
%
% Input
%  I - pole figure intensities
%  ind - pole figure index
%
% Output
%  d - coefficients
%

% extension for area detectors
if 0
  I_ext = I(solver.ext);

else % extend specimen symmetry
  lss = numProper(solver.SS);
  I_ext = repmat(I.',lss,1)./lss;
end

% compute Fourier coefficients
nfsftmex('set_f', solver.nfft_r(ind), I_ext);
nfsftmex('adjoint', solver.nfft_r(ind));
fhat = nfsftmex('get_f_hat_linear', solver.nfft_r(ind));

% convolution with kernel function
fhat = 4*pi*fhat .* solver.A;

% evaluate Fourier series at pole figure points g h_i
nfsftmex('set_f_hat_linear', solver.nfft_gh(ind), fhat);
nfsftmex('trafo', solver.nfft_gh(ind));
d = real(nfsftmex('get_f', solver.nfft_gh(ind)));
d = reshape(d,length(solver.c),[]) * solver.refl{ind}.';

end
