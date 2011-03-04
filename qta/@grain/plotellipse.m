function plotellipse(grains,varargin)
% plot ellipses of principalcomponents
%
%% Syntax
%  plotellipse(grains)
%  plotgrains(grains,'PropertyName',PropertyValue,...)
%
%% Input
%  grains - @grain
%
%% Options
%  SCALE           -  scalefactor of ellipsis 
%  HULL            -  plot the principalcomponents of convex hull
%  EllipseColor    -  colorspec
%  PrincipalAColor -  colorspec
%  PrincipalBColor -  colorspec
%
%% See also
% grain/plot grain/plotgrains grain/plotsubfractions 
% polygon/principalcomponents polygon/hullprincipalcomponents
%

plotoptions = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

scale = get_option(varargin,'scale',0.1);

if ~check_option(varargin,{'hull', 'convhull'})
  xy =  centroid(grains);
  [c v] = principalcomponents(grains);
else
  xy =  hullcentroid(grains);
  [c v] = hullprincipalcomponents(grains);
end

a = v(:,1)*scale; %axis length
b = v(:,2)*scale;  
angl = angle(c(:,1))+90*degree;
n = length(xy);

x = xy(:,1);
y = xy(:,2);

%*scale
la = [x x+real(c(:,1)).*scale]';
lb = [y y-imag(c(:,1)).*scale]';
ka = [x x+real(c(:,2)).*scale]';
kb = [y y-imag(c(:,2)).*scale]';

points = linspace(0,2*pi,100);  

cosp = cos(points);
sinp = sin(points);
cosa=cos(angl);
sina=sin(angl);
  
%%

newMTEXplot;

[cosp,sinp] = fixMTEXscreencoordinates(cosp,sinp,varargin{:});
[cosa,sina] = fixMTEXscreencoordinates(cosa,sina,varargin{:});
[la,lb] = fixMTEXscreencoordinates(la,lb,varargin{:});
[ka,kb] = fixMTEXscreencoordinates(ka,kb,varargin{:});
[x,y,lx,ly] = fixMTEXscreencoordinates(x,y,varargin{:});  

%%


for k=1:n  
  h(k)=line(a(k)*sina(k)*cosp + b(k)*cosa(k)*sinp + x(k), ...
    a(k)*cosa(k)*cosp-b(k)*sina(k)*sinp + y(k));
end

h1 = line(la,lb);
h2 = line(ka,kb);

set(h,'color',get_option(varargin,'EllipseColor','red'));
set(h1,'color',get_option(varargin,'PrincipalAColor','blue'));
set(h2,'color',get_option(varargin,'PrincipalBColor','green'));

fixMTEXplot('x',x,'y',y);





