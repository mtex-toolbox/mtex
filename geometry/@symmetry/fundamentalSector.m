function  sR = fundamentalSector(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Syntax
%   sR = fundamentalSector(cs)
%
%   % undamental sector for a specific misorientation angle
%   sR = fundamentalSector(cs,omega)
%
% Input
%  cs - @symmetry
%  omega - misorientation angle
%
% Output
%  sR - @sphericalRegion
%
% Options
%  antipodal - include [[VectorsAxes.html,antipodal symmetry]]
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
  N = zvector; % then we can map everything on the northern hemisphere
else
  N = vector3d;
end

% the region on the northern hemisphere now depends just on the
% number of symmetry operations
if numSym(cs) > 1+length(N)
  drho = 2*pi * (1+length(N)) / numSym(cs);
  N = [N,vector3d('theta',90*degree,'rho',[90*degree,drho-90*degree])];
end

% rotate fundamental sector such that it starts at the vector that is
% plotted to east
try

  % the correction angle - for some symmetries this needs to be a multiple
  % of 60 degree - this will be fixed later in the code
  cor = 0;
  if ~isempty(getMTEXpref('aStarAxisDirection',[]))
    cor = pi/2*(NWSE(getMTEXpref('aStarAxisDirection',[]))-1);
    rho = cs.aAxisRec.rho - cor;
  elseif ~isempty(getMTEXpref('bAxisDirection',[]))
    cor = pi/2*(NWSE(getMTEXpref('bAxisDirection',[]))-1);
    rho = cs.bAxis.rho - cor;
  elseif ~isempty(getMTEXpref('aAxisDirection',[]))
    cor = pi/2*(NWSE(getMTEXpref('aAxisDirection',[]))-1);
    rho = cs.aAxis.rho - cor;
  else
    rho = cs.bAxis.rho;
  end

catch
  rho = (1-NWSE(getMTEXpref('xAxisDirection')))*pi/2;
end
N = rotate(N,rho);

% some special cases
switch cs.id
  case 0 % symmetry without name - the code below works only in a very specific case
    %N = cs.subSet(cs.isImproper).axis; % take mirror planes
    %ind = angle(N,vector3d(cs.aAxis))< 45*degree;
    %N(ind) = -N(ind);

    [axes,mult] = cs.elements;

    if  max(min(1-abs(dot(axes,zvector)),abs(dot(axes,zvector))))>1e-2

      if ~cs.isLaue, axes(mult==2) = []; end

      % construct all triangles
      tri = axes(axes.calcDelaunay);

      % consider the triangle closest to the z-axis and the first quadrant
      [~,id] = min(sum(100*tri.theta + abs(mod(tri.rho-rho-pi/4+pi,2*pi)-pi)));

      sR = sphericalRegion.byVertices(tri(:,id));
      N = sR.N;
    end

  case 1 % 1
  case 2 % -1
    N = zvector;
  case {3,6,9} % 211, 121, 112
    if isnull(dot(getMinAxes(cs.rot),zvector))
      N = zvector;
    end
  case 4
    N = -getMinAxes(cs.rot);
  case {7,10} % m11, 1m1, mm1
    N = getMinAxes(cs.rot);
  case {5,8} % 2/m11 12/m1
    N = [zvector,getMinAxes(cs.rot)];
  case 11
  case 12 % 222
  case {13,14,15} % 2mm, m2m, mm2
    N = cs.rot(cs.rot.i).axis; % take mirror planes
    ind = angle(N,vector3d(cs.aAxis))< 45*degree;
    N(ind) = -N(ind);
  case 16 % mmm
  case 17 % 3
  case 18 % -3
  case {19,20,21} % 321, 3m1, -3m1
    N = rotate(N,-mod(30+round((cor)/degree),60)*degree);
  case {22} % 312
    N = rotate(N,-mod(30+round((cor)/degree),60)*degree);
  case {23,24} % -31m
    N = rotate(N,-mod(round((cor)/degree),60)*degree);
  case 30 %-42m
    N = rotate(N,-45*degree);
  case {33,34,35,36} % 6, 622
  case 38 % -62m
  case 39 % 6m2
    N = rotate(N,-mod(30+round(cor/degree),60)*degree);
  case 41 % 23
    N = rotate(vector3d([1 1 0 0],[1 -1 1 -1],[0 0 1 1]),rho);
  case {42,43} % m-3, 432
    N = rotate([vector3d(0,-1,1),vector3d(-1,0,1),xvector,yvector,zvector],rho);
  case 44 % -43m
    N = rotate([vector3d(1,-1,0),vector3d(1,1,0),vector3d(-1,0,1)],rho);
  case 45 % m-3m
    N = rotate([vector3d(1,-1,0),vector3d(-1,0,1),yvector],rho);
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
