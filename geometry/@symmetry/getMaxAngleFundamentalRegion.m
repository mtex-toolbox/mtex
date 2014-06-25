function  omega = getMaxAngleFundamentalRegion(cs)
% get the maximum angle of a fundamental region

switch cs.LaueName
  
  case {'-1','2/m','-3','4/m','6/m'}
    
    omega = pi;
    
  case {'mmm','-3m','4/mmm','6/mmm'}
    
    omega = 2*atan(sqrt(1+2*tan(pi/2 / nfold(cs))^2));
    
  case 'm-3'
    
    omega = pi/2;
    
  case 'm-3m'
    
    omega = 2*atan((sqrt(2) - 1)*sqrt(5-2*sqrt(2)));
    
end
