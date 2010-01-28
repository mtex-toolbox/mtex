function varargout = plot(q,varargin)
% plot function
%
%% Input
%  q - Quaternion
%
%% Options
%  RODRIGUES - plot in rodrigues space
%  AXISANGLE - plot in axis / angle
%
%% See also

%% two dimensional plot -> S2Grid/plot

if ~(ishold && strcmp(get(gca,'tag'),'ebsd_raster')) && ...  
  ~check_option(varargin,{'scatter','rodrigues','axisangle'}) 

  if numel(q) == 1
  
    v = [xvector,yvector,zvector];
    plot(q*v,'label',...
      {char(v(1),'Latex'),char(v(2),'Latex'),char(v(3),'Latex')},...
      varargin{:});
  
  else
  
    v = [xvector,yvector,zvector];
  
    for i = 1:numel(v)

      plot(S2Grid(q.*v(i)),varargin{:});
      hold all
    end
  
    hold off
  end
  return
end

%% threedimensioal plot


%% Prepare Axis

if ~check_option(varargin,'axis'), newplot;end
if isempty(get(gca,'children')) || all(strcmp(get(get(gca,'children'),'type'),'text'))
  rmallappdata(gcf);
end

if nargout > 0, varargout{1} = gca;end

% color
if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','DATA','MarkerEdgeColor'})
  [ls,c] = nextstyle(gca,true,true,~ishold);
  varargin = {'MarkerEdgeColor',c,varargin{:}};
end

%%  GET OPTIONS 

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% COLORMAP
if check_option(varargin,'GRAY'),colormap(flipud(colormap('gray'))/1.2);end

%% Projection

if isappdata(gcf,'projection')  
  projection = getappdata(gcf,'projection');
elseif check_option(varargin,{'rodrigues'})  
  projection = 'rodrigues';
else
  projection = 'axisangle';  
end
setappdata(gcf,'projection',projection);
set(gca,'tag','ebsd_raster');

switch projection
  case 'rodrigues'
    v = quat2rodrigues(q);
    v = v(abs(v) < 1e5);
    [x,y,z] = double(v);
  case 'axisangle'
    omega = angle(q);
    v = axis(q);
    [x,y,z] = double(v .* omega ./ degree);
end

%% scatter plot

MFC = get_option(varargin,{'MarkerFaceColor','MarkerColor'},'none');
MEC = get_option(varargin,{'MarkerEdgeColor','MarkerColor'},'b');

patch(x(:),y(:),z(:),1,...
  'FaceColor','none',...
  'EdgeColor','none',...
  'MarkerFaceColor',MFC,...
  'MarkerEdgeColor',MEC,...
  'MarkerSize',get_option(varargin,'MarkerSize',5),...
  'Marker',get_option(varargin,'Marker','o'));

view(gca,3);
grid(gca,'on')
axis vis3d equal
