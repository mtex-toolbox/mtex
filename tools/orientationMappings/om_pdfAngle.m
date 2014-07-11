function [c,options] = om_pdfAngle(o,varargin)
% converts orientations to rgb values by polar angles (theta, rho)

% compute pole figure vectors
if isa(o,'orientation')
  % get pole figure vector
  h = get_option(varargin,'h',Miller(0,0,1));
  h = o.CS.ensureCS(h);

  % symmetrise and rotate
  r = o * symmetrise(h,varargin{:});  
else
  r = o(:);
end

switch lower(get_option(varargin,'angle','rho'))
  case 'rho'
    
    c = r.rho ./ degree;
    
  case 'theta'
    
    c = r.theta ./ degree;
    
  case 'both'
    
    c = (r.theta + r.rho) ./ degree;
    
  otherwise
    
    error('unknown angle for polar colorcoding')
    
end

c = min(c,[],2);
options = varargin;
