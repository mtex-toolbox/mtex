function h = scatter3d(v,varargin)
% plot spherical data
%
% Syntax
%   scatter3d(v,data)
%
% Input
%
% See also
% savefigure

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% plot a inner sphere that is not transluent
plotEmptySphere(ax);

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

if v.antipodal   %#ok<BDSCI,BDLGI>
  v = [v;-v];
  data = [data;data];
end

% markerSize
if ~check_option(varargin,{'scatter_resolution','MarkerSize'},'double')
  res = max(v.resolution,0.5*degree);
else
  res = get_option(varargin,'scatter_resolution',1*degree);
end
MarkerSize  = get_option(varargin,'MarkerSize',min(getMTEXpref('markerSize'),50*res));


% plot
data = ensurecell(data);
h = optiondraw(scatter3(v.x(:),v.y(:),v.z(:),MarkerSize.^2,data{:},'filled','parent',ax),varargin{:});

axis(ax,'equal','vis3d','off');

set(ax,'XDir','rev','YDir','rev',...
'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);

hold(ax,'off')

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