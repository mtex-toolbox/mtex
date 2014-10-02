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

% TODO
component.kappa = component.kappa./2;

