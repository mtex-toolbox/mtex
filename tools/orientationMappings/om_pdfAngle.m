function [c,options] = om_pdfAngle(o,varargin)
% converts orientations to rgb values by polar angles (theta, rho)

% compute pole figure vectors
if isa(o,'orientation')
  % get pole figure vector
  h = get_option(varargin,'h',Miller(0,0,1));
  h = ensureCS(get(o,'CS'),ensurecell(h));

  % symmetrise and rotate
  r = o * symmetrise(h,varargin{:});  
else
  r = o(:);
end

% convert pole figure vectors to angle
[theta rho] = polar(r);

switch lower(get_option(varargin,'angle','rho'))
  case 'rho'
    
    c = rho ./ degree;
    
  case 'theta'
    
    c = theta ./ degree;
    
  case 'both'
    
    c = (theta + rho) ./ degree;
    
  otherwise
    
    error('unknown angle for polar colorcoding')
    
end

c = min(c,[],2);
options = varargin;
