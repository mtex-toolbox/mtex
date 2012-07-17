function  [maxTheta,maxRho,minRho,v,N] = getFundamentalRegionPF(cs,varargin)
% get the fundamental region for (inverse) pole figure
%
%% Input
%  cs - crystal symmetry
%
%% Ouput
%  maxTheta - 
%  maxRho   -
%  minRho   - starting rho
%  v        - some nice Miller indice
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%


maxRho = rotangle_max_z(cs);
minRho = 0;
if check_option(varargin,'antipodal') && rotangle_max_y(cs)/2 < pi
  maxRho = maxRho / 2;
end
maxTheta = rotangle_max_y(cs,varargin{:})/2;
v = [Miller(1,0,0),Miller(1,1,0),Miller(0,1,0),Miller(-1,2,0),Miller(0,0,1)];

switch Laue(cs)
  case '-3m'
    minRho = -get(Miller(1,0,-1,0,cs),'rho');
  case 'm-3m'
    if check_option(varargin,'antipodal')
      maxRho = pi/4;
      maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(mod(rho,2*maxRho)+pi));
    else
      maxRho = pi/4;
      maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(mod(rho,2*maxRho)+pi/2));
    end
    v = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1)];
  case 'm-3'
    if check_option(varargin,'antipodal')
      %maxRho = pi/4;
      %maxTheta = @(rho) pi- atan2(cos(pi/4),sin(pi/4)*cos(mod(rho,2*maxRho)+pi/2));
      maxRho = pi/2;
      maxTheta = @(rho) maxThetam3(mod(rho,maxRho));
    else
      maxRho = pi;
      maxTheta = @(rho) maxThetam3(mod(rho,maxRho));
    end
    v = [Miller(0,0,1),Miller(1,1,0),Miller(1,1,1),Miller(1,-1,1)];
  otherwise
end

if check_option(varargin,'complete')
  maxRho = 2*pi;
  maxTheta = pi;
  v = [];
end

% find a position in the first quadrant, i.e. minRho + rotate should be
rotate = get_option(varargin,'rotate',0);

minRho = mod(minRho + rotate + maxRho/2,maxRho) - rotate - maxRho/2;
maxRho = maxRho + minRho;

%% describe Fundamental region by normal to planes

switch Laue(cs)

  case 'm-3m' %ok
    
    if check_option(varargin,'antipodal')
      N = [vector3d(1,-1,0),vector3d(-1,0,1),yvector,zvector];
    else
      N = [vector3d(1,-1,0),vector3d(0,-1,1),yvector,zvector];
    end
    
  case 'm-3' %ok
        
    if check_option(varargin,'antipodal')
      N = [vector3d(0,-1,1),vector3d(-1,0,1),xvector,yvector,zvector];
    else
      N = [vector3d(0,-1,1),vector3d(-1,0,1),vector3d(1,0,1),yvector,zvector];
    end
    
  otherwise
  
    N = vector3d;
    if maxRho-minRho < 2*pi - 0.001
      N = axis2quat(zvector,[minRho,maxRho]) .* [yvector,-yvector];    
    end  
      
    if maxTheta < pi
      N = [N,zvector];
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

end
