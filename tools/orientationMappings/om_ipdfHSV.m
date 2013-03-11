function [rgb,options] = om_ipdfHSV(o,varargin)
% converts orientations to rgb values

options = extract_option(varargin,'antipodal');

% convert to Miller
if isa(o,'orientation')
  [h,r] = quat2ipdf(o,varargin{:});
  options = [{'r',r},options];
  cs = get(o,'CS');
else
  h = o;
  cs = varargin{1};  
end


% colorize fundamental region
[rgb,opt] = h2HSV(h,cs,varargin{:});

options = [options,opt];
