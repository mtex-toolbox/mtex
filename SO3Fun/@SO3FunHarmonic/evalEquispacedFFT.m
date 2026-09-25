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
% Example
%   % construct quadrature grid and evaluate there. Output will be a unique
%   % part of this grid
%   SO3F = SO3FunHarmonic.example;
%   rot = quadratureSO3Grid(62,SO3F.CS)
%   v = evalEquispacedFFT(SO3F,rot);
%
%   % for big grid sizes the construction of the quadrature grid is memory
%   % expansive. Hence construct struct, but the output is full sized
%   rot = struct('scheme','ClenshawCurtis','bandwidth',350,'CS',SO3F.CS,'SS',specimenSymmetry)
%   v = evalEquispacedFFT(SO3F,rot);
%
% See also
% SO3FunHarmonic/eval SO3FunHarmonic/evalNFSOFT SO3FunHarmonic.SO3FunHarmonic

% TODO: Extend to general equispaced grids and usage by plotting allows to
% plot SO3FunHarmonics of high bandwidth

if ~strcmp(rot.scheme,'ClenshawCurtis')
  error(['Evaluation of SO3FunHarmonics by an equispaced FFT is only implemented ' ...
         'for quadratureSO3Grid with ClenshawCurtis scheme.'])
end

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3VF,rot)
% end

% vector valued functions
if length(SO3F)>1
  f = zeros([length(rot) size(SO3F)]);
  for k=1:length(SO3F)
    F = SO3F.subSet(k);
    g = F.evalEquispacedFFT(rot,varargin{:});
    f(:,k) = g(:);
  end
  return
end


N = SO3F.bandwidth;
isReal = SO3F.isReal;


% 1) Get lattice size on [0,2pi]^3
H = [2,4,2]*rot.bandwidth + [2,0,2];


% 2) Transform harmonic/Wigner coefficients to Fourier coefficients on the
% lattice of the rotational symmetries around the Z-axis, ghat -> k x j x l
% with j = -N-1:N
SRightZ = SO3F.SRight.multiplicityZ;
SLeftZ = SO3F.SLeft.multiplicityZ;
H(1) = H(1) / SRightZ;
H(3) = H(3) / SLeftZ;
[ghat,k,l] = foldedWignerTrafo(SO3F.fhat,N,isReal,[SRightZ,SLeftZ]);


% 3) Do FFT
% every frequency goes to the index mod(frequency,H) of its FFT, summed where
% the lattice is too small for all of them; beta first and cut to [0,pi],
% then the FFTs in k and l on its H(2)/2+1 planes
f = fft(circFold(ghat,[0,-N-1,0],[size(ghat,1),H(2),size(ghat,3)]),[],2);
f = f(:,1:H(2)/2+1,:);
f = fft(fft(circFold(f,[k(1)/SRightZ,0,l(1)/SLeftZ],[H(1),H(2)/2+1,H(3)]),[],1),[],3);
if isReal, f = 2*real(f); end

% output is only the unique part of f
if isa(rot,'quadratureSO3Grid')
  f = f(rot.ifullGrid);
end

end

