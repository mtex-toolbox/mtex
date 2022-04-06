function [v,varargout] = volume(component,center,radius,varargin)
    
% for large angles or specimen symmetry take the quadrature based algorithm
if radius > pi / component.CS.multiplicityZ || ...
    numProper(component.SS) > 1
  
  % TODO this could also be computed explicitely
  [v,varargout{1:nargout-1}] = volume@ODFComponent(component,center,radius,varargin{:});
  
else
  
  v = numProper(component.CS) * (radius - sin(radius))./pi;
  varargout = varargin;
  
end
