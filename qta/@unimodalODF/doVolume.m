function [v,varargout] = doVolume(odf,center,radius,varargin)

% for large angles or specimen symmetry take the quadrature based algorithm
if radius > rotangle_max_z(odf(1).CS)/2 || length(odf(1).SS) > 1
  
  [v,varargout{1:nargout-1}] = doVolume@ODF(odf,center,radius,varargin{:});
  
else

  % compute distances
  d = reshape(odf.center.angle_outer(center,'all'),[],length(odf.center));

  % precompute volumes
  [vol,r] = volume(odf.psi,radius);

  % interpolate
  v = interp1(r,vol,d.','spline');

  % sum up
  v = sum(v.' * odf.c(:));

  varargout = varargin;
  
end
