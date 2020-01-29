function [v,varargout] = volume(component,center,radius,varargin)

% for large angles or specimen symmetry take the quadrature based algorithm
if radius > pi / component.CS.multiplicityZ || numProper(component(1).SS) > 1
  
  [v,varargout{1:nargout-1}] = volume@ODFComponent(component,center,radius,varargin{:});
  %v = volume@ODFComponent(component,center,radius,varargin{:});
  
else

  % compute distances
  d = reshape(component.center.angle_outer(center,'all'),...
    length(component.center),[]).';

  % precompute volumes
  [vol,r] = volume(component.psi,radius);

  % interpolate
  v = interp1(r,vol,d.','spline');

  % sum up
  v = sum(v.' * component.weights(:));

  varargout = varargin;
  
end
