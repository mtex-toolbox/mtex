function Z = calcPDF(component,h,r,varargin)
% calculate pdf for fibre component

Z = zeros(length(h),length(r));

sh = vector3d(symmetrise(component.h,varargin{:}));
sr = vector3d(symmetrise(component.r,component.SS));

for i = 1:length(sh)
  dh = dot_outer(sh(i).normalize,vector3d(h.normalize));
  for j = 1:length(sr)
    dr = dot_outer(sr(j).normalize,r.normalize);
    Z = Z + component.weights * component.psi.RRK(dh.',dr) / length(sh);
  end
end
