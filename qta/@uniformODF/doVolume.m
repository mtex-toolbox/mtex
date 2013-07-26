function [v,varargout] = doVolume(odf,center,radius,varargin)
    
% for large angles or specimen symmetry take the quadrature based algorithm
if radius > rotangle_max_z(odf(1).CS)/2 || length(odf(1).SS) > 1
  
  [v,varargout{1:nargout-1}] = doVolume@ODF(odf,center,radius,varargin{:});
  
else
  
  v = length(odf.CS) * (radius - sin(radius))./pi;
  varargout = varargin;
  
end
