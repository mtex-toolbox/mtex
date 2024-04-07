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
  Z = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,v,r,varargin{:}),SO3F.CS);
  return
end
if isempty(r)
  Z = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,h,v,varargin{:}),SO3F.SS);
  return
end

Z = zeros(length(h),length(r));

sh = symmetrise(normalize(SO3F.h),varargin{:});
sr = symmetrise(normalize(SO3F.r),SO3F.SS);

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
    Z = Z + SO3F.weights * psi.eval(dh.') / length(sh);
    
  end
end

end