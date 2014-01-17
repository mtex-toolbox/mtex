function [h,r] = quat2ipdf(ori,varargin)

% get specimen direction
if isa(ori,'orientation') && ...
    (strcmpi(get_option(varargin,'r',''),'auto') ||...
  check_option(varargin,'sharp'))
   
  % compute the center of the fundamental region
  cs = get(ori,'CS');
  [tmp,options] = h2HSV(xvector,cs,varargin{:});
  center = get_option(options,'colorcenter');
  
  % compute r such that mean(ori)^-1 * r = center
  r = mean(ori) * center;
  
else
  
  if isCS(get(ori,'SS'))
    r = Miller(0,0,1,get(ori,'SS'));
  else
    r = xvector;
  end
  r = get_option(varargin,'r',r,'vector3d');
  
end


% compute crystal directions
h = inv(ori) .* r;
