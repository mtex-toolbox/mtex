function f_hat = calcFourier(SO3F,varargin)
% compute harmonic coefficients of SO3Fun
%
% Syntax
%
%   f_hat = calcFourier(SO3F)
%
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

cs = SO3F.CS.properGroup;
ss = SO3F.SS.properGroup;

% the weights
c = SO3F.weights;

% the center orientations
ori = SO3F.center;

% for a few center symmetrize before computing c_hat
symCenter = 10*length(SO3F.center) * numSym(cs) * numSym(ss) < max(L^3,100);
if symCenter
  ori = symmetrise(SO3F.center,'proper');
  c = repmat(c(:).',size(ori,1),1) / numSym(cs) / numSym(ss);
end
 
varargin = delete_option(varargin,'weights',1);
SO3FH = SO3FunHarmonic.adjoint(ori,c,varargin{:},'bandwidth',L);

SO3FH = conv(SO3FH,SO3F.psi);

if ~symCenter, SO3FH = symmetrise(SO3FH); end

% add constant portion
SO3FH = SO3FH + SO3F.c0;

f_hat = SO3FH.fhat;
