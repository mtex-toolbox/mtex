function ghat = sphericalHarmonicTrafo(S2F,varargin)
% The spherical harmonic transform transfers a given harmonic series
% $$ \sum_{n=0}^N\sum_{k=-n}^n \hat{f}_n^{k} Y_n^{k}(\theta,\phi)$$
% into a bivariate Fourier series
% $$ \sum_{k,j=-N}^N \hat{g}_{k,j} e^{-i \, (k\alpha+j\beta+l\gamma)}.$$
% Therefore we just transform the harmonic coefficients
% $\hat{f}_n^{k}$ into Fourier coefficients $\hat{g}_{k,j}$ by the
% linear operator
% $$\hat{g}_{k,j} = i^{k} \, \sum_{n = \max \{|k|,|j|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k} \, d_n^{j,k}(0) \, d_n^{j,0}(0).$$
%
% Normally the indices of the output Fourier array ghat(k,j) runs over 
% k,j=-N,...,N.
%
% If SO3F is real valued the Fourier array ghat(k,j) is of size
%   k = 0,...,N
%   j = -N,...,N.
%
% If we want to use the NFFT on this Fourier array, we have to make the 
% size even, as the index set of the NFFT is -(N+1),...,N. Hence the flag
% 2^1 (make output even) yields ghat(k,j) of size
%   k = 0,...,N+mod(N+1,2)
%   j = -(N+1),...,N  
%
% flags: 
%   2^0 -> use L_2-normalized Wigner-D functions
%   2^1 -> make size of output Fourier array (ghat) even in every dimension
%   2^2 -> fhat are the Fourier coefficients of a real valued function
%   2^3 -> fhat are the Fourier coefficients of a antipodal function 
%   2^4 -> use symmetry property (not implemented yet)
% 
% Syntax
%   ghat = sphericalHarmonicTrafo(sF)
%   ghat = sphericalHarmonicTrafo(sF,flags,'bandwidth',N)
%
% Input:
%  N - double (bandwidth)
%  sF - @S2FunHarmonic
%  flags - value (2^0+2^1+...)
%
% Output:
%  ghat - double array (Fourier array with indices kxj --> theta x rho \in [0,pi]x[0,2pi))
%

N = min(S2F.bandwidth,get_option(varargin,'bandwidth',inf));

% get/set flags
if nargin>1 && isnumeric(varargin{1})
  flags = dec2bin(varargin{1});
  flags = flip(str2num(flags(:)));
  if length(flags)<5, flags(5)=0; end
else
  flags = [1,0,S2F.isReal,S2F.antipodal,0];
end

% spherical harmonic transform
flagsMEX = bin2dec(sprintf('%d',flip(flags)));
ghat = sphericalHarmonicTrafomex(N,S2F.fhat,flagsMEX,[1,1]);


% determine shift along 1st dimension
if ~flags(3) %isReal
  shift = flags(2);%makeEven
else
  shift = flags(2)*mod(N+1,2);
end

% compute row indices
if flags(3)%isReal
  k = (-shift:N)';
else
  k = (-N-shift:N)';
end

% Adjust signs to finalize the coefficient transform
ghat(:,N+1:end) = 1i.^(k) .* ghat(:,N+1:end);

% set symmetric Fourier coefficients by BMC property (see Double Fourier Sphere method)
ghat(:,1+flags(2):N+flags(2)) = (-1).^(k) .* flip(ghat(:,N+2+flags(2):end),2);

% Half the first symmetric coefficients in real valued case
if flags(3)%isReal
  ghat(1+shift,:) = ghat(1+shift,:)/2;
end

end