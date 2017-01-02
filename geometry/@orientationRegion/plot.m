function h = plot(oR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

oP = newOrientationPlot(oR.CS1,oR.CS2,'axisAngle','noBoundary',varargin{:});
hold on
color = get_option(varargin,'color',[0 0 0]);

% find the sector
ind = oR.N.angle > pi-1e-3;
sR = sphericalRegion(oR.N(ind).axis,zeros(nnz(ind),1));

% plot a grid
rho = linspace(0,2*pi,720);
theta = linspace(0,pi,13);
[rho,theta] = meshgrid(rho,theta);

r = vector3d('theta',theta.','rho',rho.');
r(~sR.checkInside(r)) = nan;
q = orientation('axis',r,'angle',oR.maxAngle(r),oP.CS1,oP.CS2);
h1 = line(q,'color',color,'parent',oP.ax,'noBoundaryCheck');

rho = linspace(0,2*pi,25);
theta = linspace(0,pi,360);
[rho,theta] = meshgrid(rho,theta);

r = vector3d('theta',theta,'rho',rho);
r(~sR.checkInside(r)) = nan;
q = orientation('axis',r,'angle',oR.maxAngle(r),oP.CS1,oP.CS2);
h2 = line(q,'color',color,'parent',oP.ax,'noBoundaryCheck');

% plot a surface
r = plotS2Grid(sR,'resolution',1*degree);
% TODO: do not use maxAngle - because this would allow us to rotate the
% orientation region
q = orientation('axis',r,'angle',oR.maxAngle(r),oP.CS1,oP.CS2);

[x,y,z] = oP.project(q,'noBoundaryCheck');
h3 = surf(x,y,z,'faceColor',color,'facealpha',0.1,'edgecolor','none');

% extract the vertices
left = oR.V(vertcat(oR.F{:}));
right = cellfun(@(x) circshift(x,1), oR.F,'UniformOutput',false);
right = oR.V(vertcat(right{:}));

% edges are just fibres connecting the vertices
f = fibre(left,right);

% some of the edges should not be ploted
f = f(angle(f.o1,f.o2,'noSymmetry')>1e-3);
f = f(angle(f.o1,'noSymmetry')<pi | angle(f.o2,'noSymmetry')<pi);

% plot the fibres
h4 = plot(f,'color',color,'linewidth',1.5,'noBoundaryCheck','parent',oP.ax);

hold off

if nargout ~= 0, h = [h1,h2,h3,h4]; end

