function S2F = radon(SO3F,h,r,varargin)
% radon transform of the SO(3) function
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
% See also

if nargin > 2 && min(length(h),length(r)) > 0 && ...
    (check_option(varargin,'old') || max(length(h),length(r)) < 10)
  
  S2F = SO3F.psi.RK_symmetrised(...
    SO3F.center,h,r,SO3F.weights,...
    SO3F.CS,SO3F.SS,varargin{:});
  return
  
end

% S2Fun in h or r?
if nargin<3 || isempty(r)
  isPF = true;
elseif isempty(h)
  isPF = false;
else
  isPF = length(h) < length(r);
end

if isPF % pole figure

  for k = 1:length(h)
    sh = symmetrise(h(k),'unique','skipantipodal');
    S2F(k) = S2FunHarmonicSym.quadrature(SO3F.center*sh,...
      repmat(SO3F.weights(:),1,length(sh)),SO3F.SS,...
      'symmetrise','bandwidth',SO3F.psi.bandwidth) ./ length(sh); %#ok<AGROW>
    
    % set result to antipodal if possible
    S2F(k).antipodal = angle(h(k),-h(k)) < 1e-3; %#ok<AGROW>
  end
  
else % inverse pole figure

  for k = 1:length(r)
    sr = symmetrise(r(k),SO3F.SS,'unique');
    S2F(k) = S2FunHarmonicSym.quadrature(inv(SO3F.center)*sr,...
      repmat(SO3F.weights(:),1,length(sr)),SO3F.CS,...
      'symmetrise','bandwidth',SO3F.psi.bandwidth) ./ length(sr); %#ok<AGROW>
  end
  
end

% convolve with radon transformed kernel function
S2F = 4 * pi * conv(S2F,SO3F.psi.radon) ;

% add uniform portion
S2F = S2F + sqrt(4*pi)*SO3F.c0;

% globaly set antipodal
if check_option(varargin,'antipodal') || SO3F.CS.isLaue || ...
    (nargin > 1 && ~isempty(h) && h.antipodal) || ...
    (nargin > 2 && ~isempty(r) && r.antipodal)
  S2F.antipodal = true;
end
