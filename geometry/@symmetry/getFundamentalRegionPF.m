function  [maxTheta,maxRho] = getFundamentalRegionPF(cs,varargin)
% get the fundamental region for (inverse) pole figure

if check_option(varargin,'complete')
  maxRho = 2*pi;
  maxTheta = pi;  
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
    case 'm-3'
    otherwise
      if check_option(varargin,'reduced') && rotangle_max_y(cs)/2 < pi
        maxRho = maxRho / 2;
      end
  end
end

