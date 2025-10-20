function f = evalEquispacedFFT(sF,v,varargin)
% Evaluate an @S2FunHarmonic on an equispaced grid in spherical coordinates
%     $$(\theta_a,\rho_b) = (\frac{\pi a}{Htheta-1},\frac{2\pi b}{Hrho})$$
% where $a=0,...,Htheta-1$ and $b=0,...,Hrho-1$.
%
% Therefore we transform the Harmonic series to an ordinary Fourier series
% equivalent as in the function <S2FunHarmonic.eval.html |eval|>.
% Afterwards, we use an equispaced FFT instead of the NFFT.
%
% Syntax
%   f = evalEquispacedFFT(sF,v)
%
% Input
%  sF - @S2FunHarmonic
%  v - @quadratureS2Grid - 'ClenshawCurtis'
%
% Output
%  f - values at this grid points
%
% Example
%   % construct quadrature grid and evaluate there. Output will be a unique
%   % part of this grid
%   sF = S2FunHarmonic.smiley;
%   v = quadratureS2Grid(100,'ClenshawCurtis');
%   f = evalEquispacedFFT(sF,v);
%
%   % for big grid sizes the construction of the quadrature grid is memory
%   % expansive. Hence construct a struct, but the output is full sized
%   v = struct('scheme','ClenshawCurtis','bandwidth',1500)
%   f = evalEquispacedFFT(sF,v);
%
% See also
% S2FunHarmonic/eval S2FunHarmonic/evalNFSFT

if ~strcmp(v.scheme,'ClenshawCurtis')
  error(['Evaluation of S2FunHarmonics by an equispaced FFT is only implemented ' ...
         'for quadratureS2Grid with ClenshawCurtis scheme.'])
end

% multivariate functions
if length(sF)>1
  f = zeros([length(v) size(sF)]);
  for k=1:length(sF)
    F = sF.subSet(k);
    g = F.evalEquispacedFFT(v,varargin{:});
    f(:,k) = g(:);
  end
  return
end


N = sF.bandwidth;
isReal = sF.isReal;
isAntipodal = sF.antipodal;


% 1) Get lattice size on [0,2pi]^2 (2-Torus) of the Clenshaw-Curtis grid
Htheta = 4*v.bandwidth;
Hrho = 2*v.bandwidth+2;


% 2) Transform spherical coefficients to Fourier coefficients
% create ghat -> k x j
% flags: 2^0 -> use L_2-normalized Wigner-D functions
%        2^2 -> fhat are the spherical coefficients of a real valued function
%        2^3 -> fhat are the spherical coefficients of a antipodal function
flags = 2^0;
if isReal
  flags = flags+2^2;
end
if isAntipodal
  flags = flags+2^3;
end
ghat = sphericalHarmonicTrafo(sF,flags,'bandwidth',N);
ghat = ghat.';


% 3) For small H we go through a smaller FFT(H) several times
% Hence we reduce the size of the fourier coefficient matrix ghat by adding 
% the coefficients with same complex exponential's.
sz = size(ghat,1,2);
if any([Htheta,Hrho]<sz)
  dim = ceil(sz./[Htheta,Hrho]);
  B = zeros(dim.*[Htheta,Hrho]);
  B(1:size(ghat,1),1:size(ghat,2)) = ghat;
  B = reshape(B,Htheta,dim(1),Hrho,dim(2));
  % Note that Htheta should be bigger than 1 to avoid errors by squeezing
  ghat = squeeze(sum(B,[2,4]));
  clear B;
end


% 4) Do FFT
f = fft2(ghat,Htheta,Hrho);


% 5) cut theta to [0,pi]
f = f(1:Htheta/2+1,:);


% 6) shift the summation of fft from [-N:N]x[-N:N] to [0:2N]x[0:2N]. 
if isReal  
  z = (0:Htheta/2)'*N/Htheta ;%+ (0:Hrho-1)*N/Hrho;
  f = 2*real( exp(2i*pi*z) .* f );
else
  z = (0:Htheta/2)'*N/Htheta + (0:Hrho-1)*N/Hrho;
  f = exp(2i*pi*z) .* f;
end

end