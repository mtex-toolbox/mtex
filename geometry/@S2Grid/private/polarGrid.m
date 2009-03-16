function polarGrid(offset,varargin)
% Plot Polar Grid
% 

circle(offset,0,pi/2,'boundary',varargin{:})

if check_option(varargin,'grid'), v = 'on';else v = 'off';end

%% latidudes
dtheta = get_option(varargin,'grid_res',30*degree);
theta = dtheta:dtheta:(pi/2-dtheta);

arrayfun(@(t) circle(offset,0,t,varargin{:},'LineStyle',':',...
  'edgecolor',[0.4 0.4 0.4],'tag','grid','visible',v),theta);

%% meridans
maxrho = getappdata(gcf,'maxrho');
minrho = getappdata(gcf,'minrho');
drho = get_option(varargin,'grid_res',30*degree);

rho = minrho:drho:(maxrho-drho);
if maxrho ~= 2*pi, rho(1) = [];end
rho = [rho;zeros(1,length(rho))];

theta = [ones(1,size(rho,2))*pi/2;zeros(1,size(rho,2))];

[X,Y] = projectData(theta,rho,varargin{:});

l = line(offset+X,Y,'LineStyle',':','color',[0.4 0.2 0.4],'tag','grid','visible',v);

% control legend entry
try
  hAnnotation = get(l,'Annotation');
  hLegendEntry = get([hAnnotation{:}],'LegendInformation');
  set([hLegendEntry{:}],'IconDisplayStyle','off')
catch %#ok<CTCH>
end

%% labels

set(gca,'xtickLabel',[]);
set(gca,'ytickLabel',[]);
if check_option(varargin,'ticks'), v = 'on';else v = 'off';end

% vertical/horizontal alignment
va = {'middle','bottom','middle','top'};
ha = {'left','center','right','center'};
r = mod(round(atan2(Y(1,:),X(1,:))/pi*2),4)+1;

% plot labels
for i = 1:size(rho,2)

  h(i) = text(offset+X(1,i),Y(1,i),[num2str(round(rho(1,i)/degree)) '°'],...
    'tag','ticks','visible',v,'interpreter','none',...
    'HorizontalAlignment',ha{r(i)},'VerticalAlignment',va{r(i)}); %#ok<AGROW>
end
if exist('h','var'), optiondraw(h);end
