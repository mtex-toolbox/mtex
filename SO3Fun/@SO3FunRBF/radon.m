function S2F = radon(SO3F,h,r,varargin)
% radon transform of the function on SO(3)
%
% Syntax
%   S2F = radon(SO3F,h,r)
%
% Input
%
% Output
%
%

if nargin > 2 && min(length(h),length(r)) > 0 && ...
    (check_option(varargin,'old') || max(length(h),length(r)) < 10)
  
  S2F = SO3F.psi.RK_symmetrised(...
    SO3F.center,h,r,SO3F.weights,...
    SO3F.CS,SO3F.SS,varargin{:});
  return
  
end

antipodal = extract_option(varargin,'antipodal');
if length(h) == 1 % pole figure

  sh = symmetrise(h,'unique');
  S2F = S2FunHarmonicSym.quadrature(SO3F.center*sh,...
    repmat(SO3F.weights(:),1,length(sh)),SO3F.SS,antipodal{:},...
    'symmetrise','bandwidth',SO3F.psi.bandwidth);

  % convolve with kernel function
  S2F = 4 * pi * conv(S2F,SO3F.psi)./ length(sh);

  % maybe we should evaluate
  if nargin > 2 && isa(r,'vector3d'), S2F = S2F.eval(r); end
  
else % inverse pole figure

  sr = symmetrise(r,SO3F.SS,'unique');
  S2F = S2FunHarmonicSym.quadrature(inv(SO3F.center)*sr,...
    repmat(SO3F.weights(:),1,length(sr)),SO3F.CS,antipodal{:},...
    'symmetrise','bandwidth',SO3F.psi.bandwidth);
  
  % convolve with kernel function
  S2F = 4 * pi * conv(S2F,SO3F.psi) ./ length(sr);

  % maybe we should evaluate
  if isa(h,'vector3d'), S2F = S2F.eval(h); end
  
end

if ~isnumeric(S2F)
  S2F.antipodal = SO3F.antipodal;
end
