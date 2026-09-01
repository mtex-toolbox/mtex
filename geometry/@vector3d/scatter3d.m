function [h,ax] = scatter3d(v,varargin)
% plot spherical data
%
% Syntax
%   scatter3d(v,data)
%
% Input
%  v - @vector3d
%

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% everything below has to accumulate into ax - the sphere, the markers and
% the grid lines - so hold it for the entire function
[hG,washeld] = holdOn(ax); %#ok<ASGLU>

% plot a inner sphere that is not translucent
isNew = ~washeld || isempty(ax.Children);
if isNew
  cla(ax)
  plotEmptySphere(ax,varargin{:});
end

% a Miller index marks the plot as living in crystal coordinates, any other
% frame names the axes of the annotation - note it before normalizing
if isa(v,'Miller'), csArg = {v.CS}; else, csArg = {'dataFrame',v.frame}; end

% normalize vectors
v = reshape(v,[],1);
v = 1.02 .* v ./ norm(v);

if nargin > 1 && isnumeric(varargin{1})
  data = varargin{1};
  data = reshape(data,length(v),[]);
  varargin{1} = [];
else
  data = {};
end

if v.antipodal
  v = [v;-v];
  data = [data;data];
end

% markerSize
if ~check_option(varargin,{'scatter_resolution','MarkerSize'},'double')
  res = max(v.resolution,0.5*degree);
else
  res = get_option(varargin,'scatter_resolution',1*degree);
end
MarkerSize  = get_option(varargin,'MarkerSize',max(1,min(getMTEXpref('markerSize'),50*res)));


% plot
data = ensurecell(data);
if isempty(data), data = {}; end
h = optiondraw(scatter3(v.x(:),v.y(:),v.z(:),MarkerSize.^2,data{:},'filled','parent',ax),varargin{:});

% add transparency if required
if check_option(varargin,{'MarkerAlpha','MarkerFaceAlpha','MarkerEdgeAlpha'})

  set(h,'MarkerFaceAlpha',get_option(varargin,{'MarkerAlpha','MarkerFaceAlpha'},1),...
    'MarkerEdgeAlpha',get_option(varargin,{'MarkerAlpha','MarkerEdgeAlpha'},1));

end

axis(ax,'equal','vis3d','off');
set(ax,'XDir','rev','YDir','rev',...
  'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);

% fromOption rather than getClass, so that the name value form
% plot(v,'3d','how2plot','y↑→x') is understood here as everywhere else
pC = plottingConvention.fromOption(varargin,plottingConvention.default);
pC.setView(ax);

% annotate the reference frame as arrows, there is no sphericalPlot to do it
if isNew, annotateFrame(ax,varargin{:},csArg{:}); end

if nargout == 0, clear h;end

end


% since the legend entry for patch object is not nice we draw an
% invisible scatter dot just for legend
%if check_option(varargin,'DisplayName')
%  holdState = get(ax,'nextPlot');
%  set(ax,'nextPlot','add');
  %optiondraw(scatter([],[],'parent',ax,'MarkerFaceColor',mfc,...
  %  'MarkerEdgeColor',mec),varargin{:});%
  %set(ax,'nextPlot',holdState);
%end