function [c,options] = om_ipdfAngle(o,varargin)
% colorize by azimuth or polar angle of inverse pole figure vectors

%% convert to Miller
if isa(o,'orientation')
  h = quat2ipdf(o,varargin{:});
  cs = get(o,'CS');
else
  h = o;
  cs = varargin{1};
end

%% compute minimum angle
h = symmetrise(Miller(h,cs),varargin{:});

% convert to polar angles
[theta,rho] = polar(h(:));

switch lower(get_option(varargin,'angle','rho'))
  case 'rho'
    
    c = rho;
    
  case 'theta'
    
    c = theta;
    
  case 'both'
    
    c = (theta + rho);
    
  otherwise
    
    error('unknown angle for polar colorcoding')
    
end

options = varargin;
c = reshape(c,size(h))./degree;
[tmp,col] = min(abs(c-min(abs(c(:,1)))));
c = c(sub2ind(size(c),col,1:size(c,2)));