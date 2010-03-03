function c = ipdf2hkl(h,cs,varargin)
% converts orientations to rgb values

%its antipodal

switch Laue(cs)
   case {'-1','2/m','-3'}
    %(:)
  otherwise
    [h,pm,rot] = project2FundamentalRegion(vector3d(h),cs,varargin{:});  
end
[theta,rho] = polar(h(:));

switch Laue(cs)
  case {'-1'}
    maxrho = pi*2/3;        
    rrho =  rho+maxrho;
    rrho( rrho> maxrho) = rrho(rrho> maxrho)-pi*2;      
    brho = (rho-maxrho);      
    brho( brho < -2*maxrho) = brho(brho< -2*maxrho)+pi*2;
    ntheta = abs (pi/2-theta)/(pi/2);
   
    r = (1-ntheta) .*  (maxrho-abs(rrho))/maxrho;
    g = (1-ntheta) .*  (maxrho-abs(rho))/maxrho;
    b = (1-ntheta) .*  (maxrho-abs(brho))/maxrho;

    r(r<0) = 0; g(g<0) = 0; b(b<0) = 0;    
    c = [r(:) g(:) b(:)];
    return
  case {'2/m' }
    maxtheta = pi/2; maxrho = pi;
    rho = abs(rho);
    rho(theta > pi/2) = mod( -rho(theta > pi/2), pi);
    theta(theta > pi/2) = mod( -theta(theta > pi/2), pi/2); 
  case 'mmm'
    maxtheta = pi/2; maxrho = pi/2;
  case '-3'    
    maxtheta = pi/2; maxrho = pi*2/3;  
    rho = mod(rho,maxrho);
    theta(theta > pi/2) = mod(-theta(theta > pi/2),pi/2);
  case '-3m'
    maxtheta = pi/2; maxrho = pi/3;
  case '4/m'
    maxtheta = pi/2; maxrho = pi/2;
  case '4/mmm'
    maxtheta = pi/2; maxrho = pi/4; 
  case '6/m'
    maxtheta = pi/2; maxrho = pi/4;
  case '6/mmm'
    maxtheta = pi/2;  maxrho = pi/6;
  case 'm-3'
    error('For symmetry ''m-3'' colorcoding is supported right now'); %#ok<WNTAG>
  case 'm-3m'
    maxtheta = pi/4; maxrho = pi/4;
end

r = 1-theta/maxtheta;
g = theta./maxtheta .* (maxrho - rho) ./ maxrho;
b = theta./maxtheta .* (rho) ./ maxrho;   

c = [r(:) g(:) b(:)];    
    
return
