function  omega = maxAngle(cs,ss)
% get the maximum angle of a fundamental region without interplay

% as we don't now which rotation axes fall together make it general.
%if nargin == 2 && length(ss) > 2
%  omega = angle_outer(quaternion(cs),quaternion(ss));
%  omega = min([pi/2;omega(omega>1e-1)/2]);
%  return
%end
 
if nargin > 1, cs = union(cs,ss);end

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

return

switch cs.id
  case [vec2cell(1:11),{17,18,25,26,33,34}] % 11x, 1x1, x11, 3,-3,4,-4,6,-6
    omega = pi;
  case vec2cell(12:16)       % 222, 
    omega = 2*pi/3;    
  case vec2cell(28:32)       % 422
    k = tan(pi/8);
    omega = 2*atan(sqrt(1+2*k^2));  
  case vec2cell(36:40)       % 622
    k = tan(pi/12);
    omega = 2*atan(sqrt(1+2*k^2));
  case {41,42}               % 23
    omega = pi/2; 
  case {43,44,45}            % 432
    k = tan(pi/8);
    omega = 2*atan(sqrt(6*k^2-4*k+1));
end

