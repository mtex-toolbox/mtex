function S2F = radon(SO3F,h,r,varargin)
% radon transform of the SO(3) function
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%
% Input
%  SO3F - @SO3FunHarmonic
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F - @S2FunHarmonic
%
% See also

% use only even Fourier coefficients?
even = check_option(varargin,'antipodal') || SO3F.CS.isLaue || ...
  (nargin > 1 && ~isempty(h) && h.antipodal) || ...
  (nargin > 2 && ~isempty(r) && r.antipodal);
even = 1 + double(even);

% bandwidth
L = get_option(varargin,'bandwidth',SO3F.bandwidth);
L = min(L,SO3F.bandwidth);

% S2Fun in h or r?
if nargin<3 || isempty(r)
  isPF = true;
elseif isempty(h)
  isPF = false;
else
  isPF = length(h) < length(r);
end

% indeces to Rf_hat
ind = cumsum([0,2*(0:L)+1]);

% calculate Fourier coefficients of the Radon transform
for l = 0:even:L
  
  if isPF  % functions with respect to r
    
    Rf_hat(1+ind(l+1):ind(l+2),:) = reshape(...
      SO3F.fhat(1+deg2dim(l):deg2dim(l+1)),2*l+1,2*l+1).' ./(2*l+1) ...
      * 4 * pi * sphericalY(l,h).';
    
  else     % functions with respect to h
    
    Rf_hat(1+ind(l+1):ind(l+2),:) = reshape(...
      conj(SO3F.fhat(1+deg2dim(l):deg2dim(l+1))),2*l+1,2*l+1) ./(2*l+1) ...
      * 4 * pi * sphericalY(l,r).';
  
  end
end

% setup a spherical harmonic function
if isPF, sym = SO3F.SS; else sym = SO3F.CS; end

S2F = S2FunHarmonicSym(conj(Rf_hat),sym);

