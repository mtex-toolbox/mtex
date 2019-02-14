function Z = calcPDF(component,h,r,varargin)
% calculate pdf for fibre component

Z = zeros(length(h),length(r));

sh = symmetrise(normalize(component.h),varargin{:});
sr = symmetrise(normalize(component.r),component.SS);

for i = 1:length(sh)
  dh = dot_outer(sh(i),h,'noSymmetry');
  for j = 1:length(sr)
    dr = dot_outer(sr(j),r,'noSymmetry');
    Z = Z + component.weights * component.psi.RRK(dh.',dr) / length(sh);
  end
end
