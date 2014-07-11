function [rgb,options] = om_ipdfHKL(o,varargin)
% converts orientations to rgb values

% convert to Miller
if isa(o,'orientation')
  h = quat2ipdf(o,varargin{:});
  cs = o.CS;
else
  h = o;
  cs = varargin{1};
end

options = varargin;

%its antipodal
% project to fundamental region
[h,pm,rho_min] = project2FundamentalRegion(vector3d(h),cs,varargin{:},'antipodal');   %#ok<ASGLU>
[theta,rho] = polar(h(:));
rho = rho - rho_min;

% get the bounds of the fundamental region
[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(cs,'antipodal');


% special case Laue -1
if strcmp(Laue(cs),'-1')
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
  rgb = [r(:) g(:) b(:)];
  return
end
  
if any(strcmp(cs.LaueName,{'m-3m','m-3'}))

  maxTheta = maxTheta(rho);

end

% compute RGB values
r = (1-theta./maxTheta);
g = theta./maxTheta .* (maxRho - rho) ./ maxRho;
b = theta./maxTheta .* rho ./ maxRho;   

rgb = [r(:) g(:) b(:)];    
    
