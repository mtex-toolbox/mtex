function [h,ax] = mapScatter(v,varargin)
% plot spherical data
%
% Syntax
%   mapScatter(v,data)
%
% Input
%  v - @vector3d
%

% create a new plot
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('parent',mtexFig.gca,varargin{:});

if nargin > 1 && isnumeric(varargin{1})
  data = varargin{1};
  data = reshape(data,length(v),[]);
  varargin{1} = [];
else
  data = {};
end

MarkerSize  = get_option(varargin,'MarkerSize',50);

% plot
data = ensurecell(data);
if isempty(data), data = {}; end
h = optiondraw(scatter3(v.x(:),v.y(:),v.z(:),MarkerSize,data{:},'filled','parent',mP.ax),varargin{:});
  
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