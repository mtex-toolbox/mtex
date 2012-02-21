function plotPlainGrid(theta,rho,varargin)
% Plot Plain Grid

axis on;
%set(gca,'GridLineStyle','.')

if check_option(varargin,'grid')
  grid on 
else
  grid off
end

dtheta = get_option(varargin,'grid_res',30*degree);
th = (min(theta(:))+dtheta):dtheta:(max(theta(:)-dtheta));
rh = rho(1)*ones(1,length(th));
[X,Y] = projectData(th,rh,varargin{:});
[Y,ind] = sort(Y);
set(gca,'ytick',Y);
setappdata(gca,'yticklabel',th(ind)/degree);
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
set(gca,'xtick',X);
setappdata(gca,'xticklabel',rh(ind)/degree);
if check_option(varargin,'gridlabel')
  set(gca,'xticklabel',rh(ind)/degree);
else
  set(gca,'xticklabel',[]);
end

%% Labels

if check_option(varargin,'label'), v = 'on'; else v = 'off'; end

optiondraw(xlabel(get_option(varargin,'xlabel','$\rho$'),...
  'visible',v,'interpreter','latex','tag','label'));

optiondraw(ylabel(get_option(varargin,'ylabel','$\theta$'),...
  'visible',v,'interpreter','latex','tag','label'));
