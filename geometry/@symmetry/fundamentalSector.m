function  sR = fundamentalSector(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Syntax
%   sR = fundamentalSector(cs)
%   sR = fundamentalSector(cs,omega) TODO: this should give the fundamental
%   sector of rotational axes for a specific rotation angle omega
%
% Input
%  cs - @symmetry
%
% Ouput
%  sR - @sphericalRegion
%
% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%

% maybe there is nothing to do
if check_option(varargin,'complete')
  sR = sphericalRegion(varargin{:});
  return
end

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

try
  aAxis = cs.axes(1);
catch
  aAxis = xvector;
end

% rotate fundamental sector such that it start with the aAxis
N = rotate(N,aAxis.rho);

% some special cases
switch cs.id
  
  case 1 % 1       
  case 2 % -1    
    N = zvector;    
  case {3,6,9} % 211, 121, 112
    if isnull(dot(getMinAxes(cs),zvector))
      N = zvector;    
    end
  case {4,7,10} % m11, 1m1, mm1
    N = getMinAxes(cs);
  case 5 % 2/m11
      N = rotate(N,-90*degree);
  case {8,11} % 12/m1 112/m      
  case 12 % 222
  case {13,14,15} % 2mm, m2m, mm2
    N = cs.subSet(cs.isImproper).axis; % take mirror planes
  case 16 % mmm    
  case 17 % 3
  case 18 % -3
  case {19,20,21} % 321, 3m1, -3m1
    N = rotate(N,-30*degree);    
  case {22,23,24} % 312, 31m, -31m
  case 30 %-42m
    N = rotate(N,-45*degree);
  case {33,34,35,36} % 6, 622    
  case 38 % -62m
  case 39 % 6m2
    N = rotate(N,-30*degree);    
  case 41 % 23    
    N = vector3d([1 1 0 0],[1 -1 1 -1],[0 0 1 1]);
  case {42,43} % m-3, 432
    N = [vector3d(0,-1,1),vector3d(-1,0,1),xvector,yvector,zvector];  
  case 44 % -43m
    N = [vector3d(1,-1,0),vector3d(1,1,0),vector3d(-1,0,1)];
  case 45 % m-3m    
    N = [vector3d(1,-1,0),vector3d(-1,0,1),yvector];
end

% this will be restricted later anyway
if check_option(varargin,{'upper','lower','maxTheta','minTheta'})
  N(N.x==0 & N.y==0) = [];
end

sR = sphericalRegion(N,zeros(size(N)),varargin{:});

% determine the fundamental sector for misorientation axes with fixed
% rotational angle
if check_option(varargin,'angle')

  omega = get_option(varargin,'angle');
  
  % the rotational axes of the symmetry
  v = unique(cs.axis); v = [v(:).',-v(:).'];
  
  % the radius of the small circles to excluded
  alpha = min(1,cot(omega./2) .* tan(pi/2 ./ cs.nfold(v)));
  
  % restrict fundamental sector
  sR.N = [sR.N,-v];
  sR.alpha = [sR.alpha,-alpha];
  
end

sR = sR.cleanUp;
