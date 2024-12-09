function ghat = wignerTrafo(SO3F,varargin)
% The Wigner transform transfers a given harmonic series
% $$ \sum_{n=0}^N\sum_{k,l=-n}^n \hat{f}_n^{k,l} D_n^{k,l}(R(\alpha,\beta,\gamma))$$
% into a trivariate Fourier series
% $$ \sum_{k,j,l=-N}^N \hat{g}_{k,j,l} e^{i \, (k\alpha+j\beta+l\gamma)}.$$
% Therefore we just transform the harmonic coefficients
% $\hat{f}_n^{k,l}$ into Fourier coefficients $\hat{g}_{k,j,l}$ by the
% linear operator
% $$\hat{g}_{k,j,l} = i^{k-l} \, \sum_{n = \max \{|k|,|j|,|l|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k,l} \, d_n^{j,k}(0) \, d_n^{j,l}(0).$$
%
% Normally the indices of the output Fourier array ghat(l,j,k) runs over 
% k,j,l=-N,...,N.
%
% If SO3F is real valued the Fourier array ghat(l,j,k) is of size
%   l = -N,...,N  
%   j = -N,...,N
%   k = 0,...,N.
%
% If we want to use the NFFT on this Fourier array, we have to make the 
% size even, as the index set of the NFFT is -(N+1),...,N. Hence the flag
% 2^1 (make output even) yields ghat(l,j,k) of size
%   l = -(N+1),...,N
%   j = -(N+1),...,N  
%   k = 0-mod(N+1,2),...,N
%
% flags: 
%   2^0 -> use L_2-normalized Wigner-D functions
%   2^1 -> make size of output Fourier array (ghat) even in every dimension
%   2^2 -> fhat are the Fourier coefficients of a real valued function
%   2^3 -> fhat are the Fourier coefficients of a antipodal function (not implemented yet)
%   2^4 -> use right and left symmetry
% 
% Syntax
%   ghat = wignerTrafo(SO3F)
%   ghat = wignerTrafo(SO3F,flags,'bandwidth',N)
%
% Input:
%  N - double (bandwidth)
%  SO3F - @SO3FunHarmonic
%  flags - value (2^0+2^1+...)
%
% Output:
%  ghat - double array (Fourier array with indices l x j x k)
%

N = min(SO3F.bandwidth,get_option(varargin,'bandwidth',inf));

if nargin>1 && isnumeric(varargin{1})
  flags = varargin{1};
else
  flags = 2^0 + SO3F.isReal*2^2 + 2^4;
end

% get symmetries
cs = SO3F.SRight;
ss = SO3F.SLeft;
sym = [min(cs.multiplicityPerpZ,2),cs.multiplicityZ,...
       min(ss.multiplicityPerpZ,2),ss.multiplicityZ];
    
% Wigner transform
ghat = wignerTrafomex(N,SO3F.fhat,flags,sym);
% reconstruct symmetric coefficients
ghat = symmetriseFourierCoefficients(ghat,flags,cs,ss,sym);

end

function test

N = 4;
cs = crystalSymmetry('1');
SO3F = SO3FunHarmonic(rand(deg2dim(N+1),2)*[2;2i]-1-1i,cs);
SO3F.CS = cs;
SO3F = SO3F.symmetrise;
SO3F.isReal = 1;
% flags
%   2^0 -> use L_2-normalized Wigner-D functions
%   2^1 -> make size of output Fourier array (ghat) even in every dimension
%   2^2 -> fhat are the Fourier coefficients of a real valued function
%   2^4 -> use right and left symmetry
flags = [1,1,0,0,1];
flags_sum = flags*2.^(0:4)';
r = rotation.rand;

ghat = wignerTrafo(SO3F,flags_sum);

abg = Euler(r,'nfft')/(2*pi);

if flags(2+1)
  e = exp(-2*pi*1i* (abg(3)*(-N-1:N)' + abg(2)*(-N-1:N) + abg(1)*reshape(0-mod(N+1,2):N,1,1,[])));
  f = 2*real( sum(ghat(:).*e(:)) )
else
  e = exp(-2*pi*1i* (abg(3)*(-N-1:N)' + abg(2)*(-N-1:N) + abg(1)*reshape(-N-1:N,1,1,[])));
  f = sum(ghat(:).*e(:))
end

SO3F.eval(r)
SO3F.evalNFSOFT(r)


end