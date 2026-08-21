function S2F = radon(SO3F,h,r,varargin)
% radon transform of a SO3FunRBF
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%
% Input
%  SO3F - @SO3FunRBF
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F - @S2FunHarmonic
%

% not multidim
if ~isscalar(SO3F)
  warning('not supported for multidim. vector fields.')
  SO3F = SO3F(1);
end

% an option in the position of r belongs to varargin
if nargin<3
  r = [];
elseif ischar(r) || isstring(r)
  varargin = [{r},varargin]; r = [];
end

% S2Fun in h or r?

if isempty(r)
  isPF = true;
elseif isempty(h)
  isPF = false;
else
  isPF = length(h) < length(r);
end

% globally set antipodal
isAntipodal = check_option(varargin,'antipodal') || SO3F.CS.isLaue || ...
  (nargin > 1 && ~isempty(h) && h.antipodal) || ...
  (nargin > 2 && ~isempty(r) && r.antipodal);

% bandwidth - the kernel carries no information beyond psi.bandwidth
bw = min(get_option(varargin,'bandwidth',SO3F.psi.bandwidth),SO3F.psi.bandwidth);

if isPF % pole figure

  for k = 1:length(h)
    sh = h(k);
    sh.antipodal = isAntipodal || angle(h(k),-h(k)) < 1e-3;
    sh = symmetrise(sh,SO3F.CS,'unique');
    
    S2F(k) = S2FunHarmonicSym.quadrature(SO3F.center*sh,...
      repmat(full(SO3F.weights(:)),1,length(sh)),SO3F.SS,...
      'symmetrise','bandwidth',bw) ./ length(sh); %#ok<AGROW>
    
  end
  
else % inverse pole figure

  r.antipodal = isAntipodal;
  for k = 1:length(r)
    sr = symmetrise(r(k),SO3F.SS,'unique');
    S2F(k) = S2FunHarmonicSym.quadrature(inv(SO3F.center)*sr,...
      repmat(SO3F.weights(:),1,length(sr)),SO3F.CS,...
      'symmetrise','bandwidth',bw) ./ length(sr); %#ok<AGROW>
  end
  
end

% convolve with radon transformed kernel function
S2F = 4 * pi * conv(S2F,SO3F.psi.radon);

% add uniform portion
S2F = S2F + SO3F.c0;

% evaluate S2Fun if needed
if  ~isempty(r) &&  ~isempty(h)
  if length(h) >= length(r)
    S2F = S2F.eval(h);
  else
    S2F = S2F.eval(r).';
  end
end

