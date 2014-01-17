function [v,varargout] = volume(component,center,radius,varargin)
    
% for large angles or specimen symmetry take the quadrature based algorithm
if radius > rotangle_max_z(component.CS)/2 || ...
    length(component.SS) > 1
  
  % TODO this could also be computed explicitely
  [v,varargout{1:nargout-1}] = volume@ODFComponent(component,center,radius,varargin{:});
  
else
  
  v = length(component.CS) * (radius - sin(radius))./pi;
  varargout = varargin;
  
end
