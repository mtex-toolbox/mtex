function h = plot(oR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

lwMinor = get_option(varargin,'lineWidthMinor',0.5);
if oR.antipodal, varargin = ['antipodal',varargin]; end
oP = newOrientationPlot(oR.CS1,oR.CS2,'axisAngle','noBoundary',varargin{:});
hold on
color = get_option(varargin,{'color','boundaryColor'},[0 0 0]);

% find the sector
ind = oR.N.angle > pi-1e-3;
sR = sphericalRegion(oR.N(ind).axis,zeros(nnz(ind),1));

% plot a grid
rho = linspace(0,2*pi,720);
theta = linspace(0,pi,13);
[rho,theta] = meshgrid(rho,theta);

r = vector3d('theta',theta.','rho',rho.');
r(~sR.checkInside(r)) = nan;
q = orientation.byAxisAngle(r,oR.maxAngle(r),oP.CS1,oP.CS2);
h1 = line(q,'color',color,'parent',oP.ax,'noBoundaryCheck','linewidth',lwMinor);

rho = linspace(0,2*pi,25);
theta = linspace(0,pi,360);
[rho,theta] = meshgrid(rho,theta);

r = vector3d('theta',theta,'rho',rho);
r(~sR.checkInside(r)) = nan;
q = orientation.byAxisAngle(r,oR.maxAngle(r),oP.CS1,oP.CS2);
h2 = line(q,'color',color,'parent',oP.ax,'noBoundaryCheck','linewidth',lwMinor);

% plot a surface
if ~check_option(varargin,'noSurface')
  r = plotS2Grid(sR,'resolution',1*degree);
  % TODO: do not use maxAngle - because this would allow us to rotate the
  % orientation region
  q = orientation.byAxisAngle(r,oR.maxAngle(r),oP.CS1,oP.CS2);
  
  [x,y,z] = oP.project(q,'noBoundaryCheck');  
  h3 = surf(x,y,z,'faceColor',color,'facealpha',0.1,'edgecolor','none');
else
  h3 = [];
end

% extract the vertices
edges = oR.V(oR.E);

% edges are just fibres connecting the vertices
if isempty(edges)
  f = fibre;
else
  f = fibre(edges(:,1),edges(:,2));
end

% ensure the right symmetry
f.CS = oP.CS;
f.SS = oP.SS;

%
color = get_option(varargin,'edgeColor',color);

% some of the edges should not be ploted
f = f(angle(f.o1,f.o2,'noSymmetry')>1e-3);
f = f(angle(f.o1,'noSymmetry')<pi | angle(f.o2,'noSymmetry')<pi);

% plot the fibres
if all(size(color) == [length(f),3])
  for i = 1:length(f)
    h4(i) = plot(f(i),'color',color(i,:),'linewidth',3,'noBoundaryCheck','parent',oP.ax);
  end
else
  lw = get_option(varargin,'linewidth',3);
  h4 = plot(f,'color',color,'linewidth',lw,'noBoundaryCheck','parent',oP.ax);
end

hold off

h = [h1,h2,h3,h4];
for i = 1:length(h)
  set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
if nargout == 0,  clear h; end