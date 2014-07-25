function ishold = getHoldState(varargin)

if nargin > 0 && ~ishandle(varargin{1})
  ax = varargin{1};
else
  ax = gca;
end

if strcmp(get(ax,'NextPlot'),'replace')
  ishold = 'off';
elseif getappdata(ax,'PlotHoldStyle')
  ishold = 'all';
else
  ishold = 'on';
end
  
