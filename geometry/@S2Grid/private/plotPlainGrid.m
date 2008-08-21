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
if check_option(varargin,'grid')
  set(gca,'ytick',Y);
else
  set(gca,'ytick',[]);
end
if check_option(varargin,'gridlabel')
  set(gca,'yticklabel',th(ind)/degree);
else
  set(gca,'yticklabel',[]);
end
drho = get_option(varargin,'grid_res',30*degree);
rh = (min(rho(:))+drho):drho:(max(rho(:)-drho));
th = theta(1)*ones(1,length(rh));
X = projectData(th,rh,varargin{:});
[X,ind] = sort(X);
if check_option(varargin,'grid')
  set(gca,'xtick',X);
else
  set(gca,'xtick',[]);
end
if check_option(varargin,'gridlabel')
  set(gca,'xticklabel',rh(ind)/degree);
else
  set(gca,'xticklabel',[]);
end
