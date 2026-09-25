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
% create ghat -> k × j
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
ghat = sphericalHarmonicTrafo(sF,flags,'bandwidth',N).';


% 3) Do FFT
% every frequency goes to the index mod(frequency,H) of its FFT, summed where
% the lattice is too small for all of them; theta first and cut to [0,pi]
f = fft(circFold(ghat,[-N,0],[Htheta,size(ghat,2)]),[],1);
f = fft(circFold(f(1:Htheta/2+1,:),[0,-N*~isReal],[Htheta/2+1,Hrho]),[],2);
if isReal, f = 2*real(f); end

end