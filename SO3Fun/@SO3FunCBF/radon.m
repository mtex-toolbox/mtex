function Z = radon(SO3F,h,r,varargin)
% calculate pdf for fibre component

if isempty(h)
  Z = S2FunHarmonicSym.quadrature(@(v) radon(SO3F,v,r,varargin{:}),SO3F.CS);
  return
elseif nargin>2 && isempty(r)
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

    Plr = legendre0(length(SO3F.psi.A)-1,dr);
    psi = conv(SO3F.psi,Plr);

    Z = Z + SO3F.weights * psi.eval(dh.') / length(sh);
     
  end
end

end
