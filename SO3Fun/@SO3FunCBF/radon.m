function Z = radon(SO3F,h,r,varargin)
% calculate pdf for fibre component

Z = zeros(length(h),length(r));

sh = symmetrise(normalize(SO3F.h),varargin{:});
sr = symmetrise(normalize(SO3F.r),SO3F.SS);

for i = 1:length(sh)
  dh = dot_outer(sh(i),normalize(h),'noSymmetry');
  for j = 1:length(sr)
    dr = dot_outer(sr(j),r,'noSymmetry');
    Z = Z + SO3F.weights * SO3F.psi.RRK(dh.',dr) / length(sh);
  end
end
