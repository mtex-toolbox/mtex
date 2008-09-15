function polarGrid(offset,varargin)
% Plot Polar Grid
% 

if check_option(varargin,'grid'), v = 'on';else v = 'off';end

dtheta = get_option(varargin,'grid_res',30*degree);
theta = dtheta:dtheta:(pi/2-dtheta);
rho = zeros(1,length(theta));
[X,Y] = projectData(theta,rho,varargin{:});
X = sqrt(sum(X(:).^2+Y(:).^2,2));

arrayfun(@(x) circle(offset,0,x,'LineStyle',':',...
  'edgecolor',[0.4 0.4 0.4],'tag','grid','visible',v),X);


%% meridans
drho = get_option(varargin,'grid_res',30*degree);
rho = [0:drho:(pi-drho);pi:drho:(2*pi-drho)];
theta = ones(size(rho))*pi/2;
[X,Y] = projectData(theta,rho,varargin{:});

line(offset+X,Y,'LineStyle',':','color',[0.4 0.2 0.4],'tag','grid','visible',v);

%% labels

set(gca,'xtickLabel',[]);
set(gca,'ytickLabel',[]);
if check_option(varargin,'ticks'), v = 'on';else v = 'off';end
va = {'middle','bottom','middle','top'};
ha = {'left','center','right','center'};

for i = 1:numel(rho)

  r = mod(round(atan2(Y(i),X(i))/pi*2),4)+1;
  optiondraw(text(offset+X(i),Y(i),[num2str(round(rho(i)/degree)) '°'],...
    'tag','ticks','visible',v,...
    'HorizontalAlignment',ha{r},'VerticalAlignment',va{r}));
end
