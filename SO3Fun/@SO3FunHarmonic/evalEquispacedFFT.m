function f = evalEquispacedFFT(SO3F,rot,varargin)
% Evaluate an @SO3FunHarmonic on an equispaced grid in Euler angles
%     $$(\alpha_a,\beta_b,\gamma_c) = (\frac{2\pi a}{H_1},\frac{\pi b}{H_2-1},\frac{2\pi c}{H_3})$$
% where $a=0,...,H_1-1$, $b=0,...,H_2-1$ and $c=0,...,H_3-1$.
%
% Therefore we transform the Harmonic series to an usual Fourier series
% equivalent as in the function <SO3FunHarmonic.eval.html |eval|>.
% But we use an equispaced FFT instead of the NFFT.
%
% Syntax
%   f = evalEquispacedFFT(SO3F,rot)
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot - @quadratureSO3Grid - 'ClenshawCurtis'
%
% Output
%  f - values at this grid points
%  nodes - @orientation
%
% See also
% SO3FunHarmonic/eval SO3FunHarmonic/evalNFSOFT SO3FunHarmonic/evalSectionsEquispacedFFT

if ~strcmp(rot.scheme,'ClenshawCurtis')
  error(['Evaluation of SO3FunHarmonics by an equispaced FFT is only implemented ' ...
         'for quadratureSO3Grid with ClenshawCurtis scheme.'])
end

ensureCompatibleSymmetries(SO3F,rot)

% multivariate functions
if length(SO3F)>1
  f = zeros([length(rot) size(SO3F)]);
  for k=1:length(SO3F)
    F = SO3F.subSet(k);
    g = F.evalEquispacedFFT(rot);
    f(:,k) = g(:);
  end
  return
end


N = SO3F.bandwidth;
isReal = SO3F.isReal;


% 1) Get lattice size on [0,2pi]^3
H = [2,4,2]*rot.bandwidth + [2,0,2];


% 2) Transform harmonic/Wigner coefficients to Fourier coefficients
% create ghat -> k x j x l
% flags: 2^0 -> use L_2-normalized Wigner-D functions
%        2^2 -> fhat are the fourier coefficients of a real valued function
%        2^4 -> use right and left symmetry
if isReal
  flags = 2^0+2^2+2^4;
  sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
    min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
  ghat = representationbased_coefficient_transform(N,SO3F.fhat,flags,sym);
  ghat = symmetriseFourierCoefficients(ghat,flags,SO3F.SRight,SO3F.SLeft,sym);
else
  flags = 2^0+2^4;
  sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
    min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
  ghat = representationbased_coefficient_transform(N,SO3F.fhat,flags,sym);
  ghat = symmetriseFourierCoefficients(ghat,flags,SO3F.SRight,SO3F.SLeft,sym);
end


% 3) correct ghat by i^(-k+l)
if isReal
  z = (1i).^((-N:N)' - reshape(0:N,1,1,[]));
else
  z = (1i).^((-N:N)' - reshape(-N:N,1,1,[]));
end
ghat = ghat .* z;


% 4) use rotational symmetries around Z-axis to speed up 
% (cut zeros in ghat)
SRightZ = SO3F.SRight.multiplicityZ;
SLeftZ = SO3F.SLeft.multiplicityZ;
H(1) = H(1) / SRightZ;
H(3) = H(3) / SLeftZ;
if SLeftZ>1 || SRightZ>1
  ind1 =  [-flip(SRightZ:SRightZ:N),(0:SRightZ:N)] + (N+1);
  if isReal
    ind3 =  (0:SLeftZ:N)+1;
  else
    ind3 =  [-flip(SLeftZ:SLeftZ:N),(0:SLeftZ:N)] + (N+1);
  end
  ghat = ghat(ind1,:,ind3);
end


% 5) For small H we go through a smaller FFT(H) several times
% Hence we reduce the size of the fourier coefficient matrix ghat by adding 
% the coefficients with same complex exponentials.
sz = size(ghat,1,2,3);
if any(H<sz)
  dim = ceil(sz./H);
  B = zeros(dim.*H);
  B(1:size(ghat,1),1:2*N+1,1:size(ghat,3)) = ghat;
  B = reshape(B,H(1),dim(1),H(2),dim(2),H(3),dim(3));
  % Note that H(1) and H(2) should be biger than 1 to avoid errors by squeezing
  ghat = squeeze(sum(B,[2,4,6]));
  clear B;
end


% 6) Do FFT
f = fftn(ghat,H);
% cut beta to [0,pi]
f = f(:,1:H(2)/2+1,:);
% shift the summation of fft from [-|_N/r_|:|_N/r_|]x[-N:N]x[-|_N/s_|:|_N/s_|] to
% [0:2*|_N/r_|]x[0:2N]x[0:2*|_N/s_|]. With r- & s-fold rotational symmetry
% around Z-axis and |_ ... _| denotes the round off operator.
z = (0:H(1)-1).' * (floor(N/SRightZ)/H(1)) + (0:H(2)/2) * (N/H(2));
if isReal  
  f = 2*real( exp(2i*pi*z) .* f );
else
  z = z + reshape(0:H(3)-1,1,1,[]) * (floor(N/SLeftZ)/H(3));
  f = exp(2i*pi*z) .* f;
end

% output is only the unique part of f
f = f(rot.ifullGrid);

end