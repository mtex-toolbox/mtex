function polarGrid(offset,varargin)
% Plot Polar Grid
% 
dtheta = get_option(varargin,'grid_res',30*degree);
theta = dtheta:dtheta:(pi/2-dtheta);
rho = zeros(1,length(theta));
X = projectData(theta,rho,varargin{:});

arrayfun(@(x) circle(offset,0,x,'LineStyle',':','edgecolor',[0.4 0.4 0.4]),X);


% meridans
drho = get_option(varargin,'grid_res',30*degree);
rho = [0:drho:(pi-drho);pi:drho:(2*pi-drho)];
theta = ones(size(rho))*pi/2;
[X,Y] = projectData(theta,rho,varargin{:});

line(offset+X,Y,'LineStyle',':','color',[0.4 0.2 0.4]);
