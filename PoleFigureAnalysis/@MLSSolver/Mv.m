function I = Mv(solver,c,i)
% forward operator
%
% Input
%  solver - Solver
%  c - coefficients
%  i - pole figure index
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

if isfield(solver.pf.prop,'bankId')
  % average values over a bank
  I = accumarray(solver.pf.prop.bankId{i},I,[max(solver.pf.prop.bankId{i}),1],@mean);

  % expand
  I = I(solver.pf.prop.bankId{i});
else

  % sum up specimen symmetry
  I = mean(reshape(I,[],length(solver.pf,i)),1).';
end

end  
