function Z = calcPDF(component,h,r,varargin)
% calculate pdf for fibre component
%
% Syntax
%   value = calcPDF(odf,h,r)
%
% Input
%  odf - @fibreComponent
%  h   - @Miller / @vector3d crystal directions
%  r   - @vector3d specimen directions
%
% Output
%  pdf - pole density @double
%

Z = zeros(length(h),length(r));

sh = symmetrise(normalize(component.h),varargin{:});
sr = symmetrise(normalize(component.r),component.SS);

for i = 1:length(sh)
  dh = dot_outer(sh(i),normalize(h),'noSymmetry');
  for j = 1:length(sr)
    dr = dot_outer(sr(j),r,'noSymmetry');
    Z = Z + component.weights * component.psi.RRK(dh.',dr) / length(sh) / length(sr);
  end
end
