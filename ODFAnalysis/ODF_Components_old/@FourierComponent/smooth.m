function component = smooth(component,psi)
% smooth ODF component
%
% Input
%  component - @ODFComponent
%  res - resolution
%
% Output
%  component - smoothed @ODFComponent
%

L = min(component.bandwidth,find(psi.A,1,'last')-1);

component.f_hat = component.f_hat(1:deg2dim(L+1));
for l = 0:L
  component.f_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
    component.f_hat(deg2dim(l)+1:deg2dim(l+1)) * psi.A(l+1);
end
