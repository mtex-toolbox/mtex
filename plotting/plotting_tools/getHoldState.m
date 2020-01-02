function ishold = getHoldState(varargin)

if nargin > 0 && ~ishandle(varargin{1})
  ax = varargin{1};
else
  ax = gca;
end

if any(strcmp(get(ax,'NextPlot'),{'replaceChildren','replace'}))
  ishold = 'off';
elseif getappdata(ax,'PlotHoldStyle')
  ishold = 'all';
else
  ishold = 'on';
end
  
