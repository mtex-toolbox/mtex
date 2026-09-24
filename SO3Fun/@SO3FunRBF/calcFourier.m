function f_hat = calcFourier(SO3F,varargin)
% compute harmonic coefficients of SO3Fun
%
% Syntax
%   f_hat = calcFourier(SO3F)
%   f_hat = calcFourier(SO3F,'bandwidth',L)
%
% Input
%  SO3F - @SO3FunRBF
%  L    - maximum harmonic degree / bandwidth
%
% Output
%  f_hat - harmonic/Fouier/Wigner-D coefficients
%

L = get_option(varargin,'bandwidth',min(SO3F.bandwidth,getMTEXpref('maxSO3Bandwidth')));

% the weights
c = SO3F.weights;

% the center orientations, the adjoint projects onto the symmetric functions
ori = SO3F.center;

varargin = delete_option(varargin,'weights',1);

% For many center orientations round them onto a regular quadrature grid
% and use the plain FFT based adjoint transform instead of the NFFT, see
% SO3FunHarmonic.adjoint. The rounding error (at most half the grid
% spacing, i.e. pi/(4L)) is negligible compared to the kernel halfwidth.
% The FFT costs O(L^3 log L) independently of the number of orientations
% while the NFFT scales linearly with it - the measured crossover is at
% about 10*L^3 orientations.
if length(ori) > 10*L^3 && ~check_option(varargin,'exact')
  varargin = [varargin,{'gridded'}];
end

SO3FH = SO3FunHarmonic.adjoint(ori,c,varargin{:},'bandwidth',L);
SO3FH = reshape(SO3FH,size(SO3F));

SO3FH = conv(SO3FH,SO3F.psi);

% add constant portion
SO3FH = SO3FH + SO3F.c0;

f_hat = SO3FH.fhat;
