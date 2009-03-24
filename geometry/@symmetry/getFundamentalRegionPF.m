function  [maxTheta,maxRho,v] = getFundamentalRegionPF(cs,varargin)
% get the fundamental region for (inverse) pole figure

if check_option(varargin,'complete')
  maxRho = 2*pi;
  maxTheta = pi;  
  v = [];
else
  maxRho = rotangle_max_z(cs);
  maxTheta = rotangle_max_y(cs,varargin{:})/2;
    
  switch Laue(cs)
    case 'm-3m'
      if check_option(varargin,'reduced')
        maxRho = pi/4;  
        maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(rho+pi));        
      else
        maxRho = pi/4;
        maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(rho+pi/2));
      end
      v = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
    case 'm-3'
      if check_option(varargin,'reduced')
        maxRho = pi/4;
        maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(rho+pi/2));        
      else
        maxRho = pi;
        maxTheta = @(rho) maxThetam3(rho);
      end
      v = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
    otherwise
      v = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)];
      if check_option(varargin,'reduced') && rotangle_max_y(cs)/2 < pi
        maxRho = maxRho / 2;
      end
  end
end

function maxTheta = maxThetam3(rho)

maxTheta = pi/2 * ones(size(rho));
ind = rho <= pi/4;
maxTheta(ind) = pi- atan2(cos(pi/4),sin(pi/4)*cos(rho(ind)+pi));
ind = rho>pi/4 & rho <= 3/4*pi;
maxTheta(ind) = pi- atan2(cos(pi/4),sin(pi/4)*cos(rho(ind)+pi/2));
ind = rho>pi*3/4;
maxTheta(ind) = pi- atan2(cos(pi/4),sin(pi/4)*cos(rho(ind)));

