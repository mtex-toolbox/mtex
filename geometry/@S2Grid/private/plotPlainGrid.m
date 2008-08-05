function plotPlainGrid(theta,rho,varargin)
% Plot Plain Grid

axis on;
%set(gca,'GridLineStyle','.')
grid on
dtheta = get_option(varargin,'grid_res',30*degree);
th = (min(theta(:))+dtheta):dtheta:(max(theta(:)-dtheta));
rh = rho(1)*ones(1,length(th));
[X,Y] = projectData(th,rh,varargin{:});
[Y,ind] = sort(Y);
set(gca,'ytick',Y);
if get_option(varargin,'gridlabel')
  set(gca,'yticklabel',th(ind)/degree);
end
drho = get_option(varargin,'grid_res',30*degree);
rh = (min(rho(:))+drho):drho:(max(rho(:)-drho));
th = theta(1)*ones(1,length(rh));
X = projectData(th,rh,varargin{:});
[X,ind] = sort(X);
set(gca,'xtick',X);
if get_option(varargin,'gridlabel')
  set(gca,'xticklabel',rh(ind)/degree);
end
