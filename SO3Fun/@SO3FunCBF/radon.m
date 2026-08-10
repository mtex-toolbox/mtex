function Z = radon(SO3F,h,r,varargin)
% radon transform of a fibre SO3Fun
%
% Syntax
%   S2F = radon(SO3F,h)
%   S2F = radon(SO3F,[],r)
%   v = radon(SO3F,h,r)
%
% Input
%  SO3F - @SO3FunCBF
%  h    - @vector3d, @Miller
%  r    - @vector3d, @Miller
%
% Output
%  S2F  - @S2FunHarmonic
%  v    - double
%

if nargin<3, r = []; end

if length(h)>1 && length(r)>1
  error('The length of h or r has to be smaller than 1.')
end

if isempty(h)
  % as a function of the crystal direction the inverse pole figure is even
  % whenever -r is symmetrically equivalent to r
  ap = isAntipodal(r,SO3F.SS,varargin{:});
  Z = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,v,r,varargin{:}),...
    SO3F.CS,varargin{:},ap{:});
  return
end
if isempty(r)
  % as a function of the specimen direction the pole figure is even
  % whenever -h is symmetrically equivalent to h
  ap = isAntipodal(h,SO3F.CS,varargin{:});
  Z = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,h,v,varargin{:}),...
    SO3F.SS,varargin{:},ap{:});
  return
end

Z = zeros(length(h),length(r));

for k = 1:length(SO3F.h)
  
  sh = symmetrise(normalize(SO3F.h(k)),varargin{:});
  sr = symmetrise(normalize(SO3F.r(k)),SO3F.SS);

  for i = 1:length(sh)
    dh = dot_outer(sh(i),normalize(h),'noSymmetry');
    for j = 1:length(sr)
      dr = dot_outer(sr(j),r,'noSymmetry');

      if length(dr)~=1
        s = dr;
        dr = dh.';
        dh = s.';
      end
      Plr = legendre0(length(SO3F.psi.A)-1,dr);
      psi = conv(SO3F.psi,Plr);
      Z = Z + SO3F.weights(k) * psi.eval(dh.') / length(sh);
    end
  end
end

end

function ap = isAntipodal(v,sym,varargin)
% The Radon transform is an even function of the free variable whenever -v
% is symmetrically equivalent to v. Note that angle(v,-v) takes the
% symmetry of a Miller index into account, i.e. it returns 0 for the c-axis
% of a trigonal crystal symmetry. Without this the tiny quadrature error
% below leaves the result just short of being recognized as antipodal.

if check_option(varargin,'antipodal') || sym.isLaue || v.antipodal || ...
    all(angle(v,-v) < 1e-3)
  ap = {'antipodal'};
else
  ap = {};
end

end
