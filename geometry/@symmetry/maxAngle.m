function  omega = maxAngle(cs,ss)
% get the maximum angle of a fundamental region without interplay

% as we don't now which rotation axes fall together make it general.
%if nargin == 2 && length(ss) > 2
%  omega = angle_outer(quaternion(cs),quaternion(ss));
%  omega = min([pi/2;omega(omega>1e-1)/2]);
%  return
%end

% TODO: this needs to be rethought
if nargin > 1
  omega = min(maxAngle(cs),maxAngle(ss));
  %cs = union(cs,ss);
end

switch cs.LaueName
  
  case {'-1','2/m','-3','4/m','6/m','12/m1','2/m11','112/m'}
    
    omega = pi;
    
  case {'mmm','-3m','4/mmm','6/mmm','-3m1','-31m'}
    
    omega = 2*atan(sqrt(1+2*tan(pi/2 / nfold(cs))^2));
    
  case 'm-3'
    
    omega = pi/2;
    
  case 'm-3m'
    
    omega = 2*atan((sqrt(2) - 1)*sqrt(5-2*sqrt(2)));
    
end


