function mtexColorMap(arg1,varargin)
% define an MTEX colormap

% get input
if length(arg1)==1 && ishandle(arg1) &&...
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
