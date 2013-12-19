function labelcontours(varargin)
% bypasses the clabel function for multiplot enviroment
%
%% See also
% clabel

fig = get(0,'currentfigure');
if isempty(fig) || ~isappdata(fig,'axes')
  error('no multiplot to label')
end

ax = getappdata(fig,'axes');

for i = 1:numel(ax)
  axChildren = get(ax(i),'children');
  
  for k = 1:numel(axChildren)
    h = axChildren(k);
    if isa(handle(h),'specgraph.contourgroup')
      CM = get(h,'ContourMatrix');
      clabel(CM,h,varargin{:});
    end
  end
  
end

