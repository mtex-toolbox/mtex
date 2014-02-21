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

component.psi = component.psi * psi;

