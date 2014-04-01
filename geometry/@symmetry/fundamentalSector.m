function  sR = fundamentalSector(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Input
%  cs - symmetry
%
% Ouput
%  sR - spherical Region
%
% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%

% antipodal symmetry is nothing else then adding inversion to the symmetry
% group
if check_option(varargin,'antipodal'), cs = cs.Laue; end

% a first very simple rule for the fundamental region

% if we have an inversion or some symmetry operation no parallel to z
if any(angle(zvector,symmetrise(zvector,cs))>pi/2+1e-4)  
  N = zvector; % then we can map everything on the norther hemisphere
else
  N = vector3d;
end

% the region on the northern hemisphere now depends just on the
% number of symmetry operations
if length(cs) > 1+length(N)
  drho = 2*pi * (1+length(N)) / length(cs);
  N = [N,vector3d('theta',90*degree,'rho',[90*degree,drho-90*degree])];
end

% TODO correct for different alignments in 32

% some special cases
switch cs.id
  
  case 1 % 1
       
  case 2 % -1
    
    N = zvector;
    
  case 3 % 2
    
    if isnull(dot(getMinAxes(cs),zvector))
      N = zvector;
    else
      ind = find(isnull(dot(getMinAxes(cs),cs.axes)),1);
      N = cs.axes(ind);
    end
  case 4 % m
    
  case 5 % 2/m
    
  case 6 % 222
  case 7 % 22
  case 8 % 2mm
  case 9 % mm2
  case 10 % mmm
  case 11 % 32
    h = Miller(1,0,0,cs);
    N = rotate(N,rotation('axis',zvector,'angle',h.rho-120*degree));
  case 13
    h = Miller(1,0,0,cs);
    N = rotate(N,rotation('axis',zvector,'angle',h.rho-120*degree));
  case 19 %-42m
    N = rotate(N,-45*degree);
  case 26
    N = rotate(N,-30*degree);
  case 28 % 23
    N = [vector3d(0,-1,1),vector3d(-1,0,1),vector3d(1,0,1),yvector,zvector];
  case 29 % m-3
    N = [vector3d(0,-1,1),vector3d(-1,0,1),xvector,yvector,zvector];
  case 30 % 432
    N = [vector3d(1,-1,0),vector3d(0,-1,1),yvector];
  case 31 % -43m
    N = [vector3d(1,-1,0),vector3d(1,1,0),vector3d(-1,0,1)];
  case 32 % m-3m    
    N = [vector3d(1,-1,0),vector3d(-1,0,1),yvector];
end

if check_option(varargin,{'complete','3d'})
  sR = sphericalRegion;
else
  sR = sphericalRegion(N);
end

return

% default values from the symmetry
minTheta = 0;
maxRho = cs.rotangle_max_z;
minRho = 0;
if check_option(varargin,'antipodal') && cs.rotangle_max_y/2 < pi
  maxRho = maxRho / 2;
end
maxTheta = cs.rotangle_max_y(varargin{:})/2;
v = [Miller(1,0,0),Miller(1,1,0),Miller(0,1,0),Miller(-1,2,0),Miller(0,0,1)];

fak = 2;
switch cs.LaueName
  case '-3m'
    minRho = mod(cs.axes(1).rho,120*degree);
    if check_option(varargin,'antipodal')
      minRho = minRho-30*degree;
      fak = 1;
    end
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

%

if check_option(varargin,{'complete','3d'})
  minRho = 0;
  maxRho = 2*pi;
  minTheta = 0;
  maxTheta = pi;
  v = [];
else
  
  % try to make minRho close to true x Axis  
  drho = minRho - (1-NWSE(getMTEXpref('xAxisDirection')))*90*degree;  
  drho = ceil(round(100*drho./maxRho*fak)./100)*maxRho/fak;
  minRho = minRho - drho;
  
  v.CS = cs;
  opt = extract_option(varargin,'antipodal');
  v = unique(v,opt{:});
end

% get values from direct options
minTheta = get_option(varargin,'minTheta',minTheta);
maxTheta = get_option(varargin,'maxTheta',maxTheta);
minRho   = get_option(varargin,'minRho',minRho);
maxRho = maxRho + minRho;
maxRho   = get_option(varargin,'maxRho',maxRho);

% restrict using meta options upper, lower



if check_option(varargin,'upper') && isnumeric(maxTheta) && maxTheta > pi/2
  maxTheta = pi/2;
end

if check_option(varargin,'lower') && isnumeric(maxTheta) && maxTheta > pi/2+0.001
  
  minTheta = pi/2;

elseif check_option(varargin,'restrict2Hemisphere') ...
    && isnumeric(maxTheta) && maxTheta>pi/2
  
  maxTheta = pi/2;

end


% TODO
% find a position in the first quadrant, i.e. minRho + rotate should be
%rotate = get_option(varargin,'rotate',0);


% describe Fundamental region by normal to planes
switch cs.LaueName

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

sR = sphericalRegion(N);

end

% --------------- private functions -----------------------
function maxTheta = maxThetam3(rho)

maxTheta = pi/2 * ones(size(rho));
ind = rho <= pi/4;
maxTheta(ind) = pi- atan2(cos(pi/4),sin(pi/4)*cos(rho(ind)+pi));
ind = rho>pi/4 & rho <= 3/4*pi;
maxTheta(ind) = pi- atan2(cos(pi/4),sin(pi/4)*cos(rho(ind)+pi/2));
ind = rho>pi*3/4;
maxTheta(ind) = pi- atan2(cos(pi/4),sin(pi/4)*cos(rho(ind)));

end
