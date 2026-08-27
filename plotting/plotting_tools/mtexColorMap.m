function mtexColorMap(arg1,varargin)
% set the colormap of an MTEX plot
%
% Syntax
%
%   mtexColorMap white2black       % every axes of the current figure
%   mtexColorMap(gcf,'white2black')
%   mtexColorMap(ax,'white2black') % one axes only
%   mtexColorMap(ax,map)           % an n × 3 matrix of rgb values
%
% Input
%  ax   - @axis or figure handle, defaults to the current figure
%  name - name of the colormap, with or without the |ColorMap| suffix
%  map  - n × 3 rgb, as returned by |colormap|
%
% Description
% Without a handle, or with a figure handle, the colormap is applied to
% *every* axes of that figure - an @mtexFigure holding e.g. several ODF
% sections is one figure, so all of its sections share the colour scale,
% which is what a common scale for one function should do. To give the
% subplots of a figure different colormaps - several different ODFs next to
% each other, say - pass the individual axes handle instead:
%
%   plot(odf1); ax1 = gca;
%   nextAxis; plot(odf2); ax2 = gca;
%   mtexColorMap(ax1,'hot'); mtexColorMap(ax2,'jet');
%
% See also
% colormap mtexColorbar

% get input
if isscalar(arg1) && ishandle(arg1) &&...
    (isa(arg1,'axis') || isa(arg1,'matlab.graphics.axis.Axes') || isa(arg1,'matlab.ui.Figure'))
  ax = arg1;
  name = varargin{1};
else
  ax = gcf;
  name = arg1;
end

% get axes
try
  mtexFig = getappdata(ax,'mtexFig');
  ax = mtexFig.children;
end

% detect colormap
if ischar(name)
  if isempty(which([name '.m']))
    name = [name,'ColorMap'];
    if isempty(which(name))
      error('unknown colormap name');      
    end
  end
  if strcmp(name,'zero2whiteColorMap')
    for i = 1:length(ax)
      map = feval(name,ax(i).CLim);
      colormap(ax(i),map); 
    end
    return
  end
  try
    map = feval(name);
  catch
    map = feval(lower(name));
  end
else
  map = name;
end

% apply the colormap
for i = 1:length(ax), colormap(ax(i),map); end

end
