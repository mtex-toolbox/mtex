function  [maxTheta,maxRho,minRho,v] = getFundamentalRegionPF(cs,varargin)
% get the fundamental region for (inverse) pole figure
%
%% Input
%  cs - crystal symmetry
%
%% Ouput
%  maxTheta
%  maxRho
%  minRho
%  v
%
%% Options
%  axial      - include [[AxialDirectional.html,antipodal symmetry]]
%
%

rotate = get_option(varargin,'rotate',0);
if check_option(varargin,'complete')
  minRho = 0;
  maxRho = 2*pi;
  maxTheta = pi;  
  v = [];
else  
  
  maxRho = rotangle_max_z(cs);
  if check_option(varargin,'axial') && rotangle_max_y(cs)/2 < pi
    maxRho = maxRho / 2;
  end
  maxTheta = rotangle_max_y(cs,varargin{:})/2;
  v = [Miller(1,0,0),Miller(1,1,0),Miller(0,1,0),Miller(-1,2,0),Miller(0,0,1)];

  switch Laue(cs)
    case '-3m'
      if check_option(varargin,'axial') && ...
        xor(isappr(rem(rotate,60*degree),0),...
          isappr(norm(xvector - vector3d(Miller(1,0,0,cs))),0))
        rotate = rotate - 30*degree;
      end
    case 'm-3m'
      if check_option(varargin,'axial')
        maxRho = pi/4;  
        maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(mod(rho,2*maxRho)+pi));        
      else
        maxRho = pi/4;
        maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(mod(rho,2*maxRho)+pi/2));
      end
      v = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
    case 'm-3'
      if check_option(varargin,'axial')
        maxRho = pi/4;
        maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(mod(rho,2*maxRho)+pi/2));        
      else
        maxRho = pi;
        maxTheta = @(rho) maxThetam3(mod(rho,maxRho));
      end
      v = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1),Miller(1,-1,1)];
    otherwise
            
  end
  
  if maxRho < 2*pi 
    minRho = -rotate;
    maxRho = maxRho - rotate;
  else
    minRho = 0;
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

