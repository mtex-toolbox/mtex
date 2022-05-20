function [v,varargout] = volume(SO3F,center,radius,varargin)

% for large angles or specimen symmetry take the quadrature based algorithm
if radius > pi / SO3F.CS.multiplicityZ || ...
    length(SO3F(1).SS) > 1
  
  [v,varargout{1:nargout-1}] = volume@SO3Fun(SO3F,center,radius,varargin{:});
  
elseif isempty(SO3F.center)
  
  v =  zeros(size(center)) + SO3F.c0 * numProper(SO3F.CS) * (radius - sin(radius))./pi;
  varargout = varargin;

else

  % compute distances
  d = SO3F.center.angle_outer(center,'all');
  s = size(d);
  d = reshape(d, length(SO3F.center),[]).';
  
  % precompute volumes
  [vol,r] = volume(SO3F.psi,radius);
  
  % interpolate
  v = interp1(r,vol,d.','spline');
  
  % sum up
  v = v.' * SO3F.weights(:);
  v = sum(reshape(v,s(2:end)),length(s)-1);
  
  % add uniform portion
  v = v + SO3F.c0 * numProper(SO3F.CS) * (radius - sin(radius))./pi;
 
  varargout = varargin;
  
end
