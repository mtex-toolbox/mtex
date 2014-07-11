function varargout = colorbar(varargin)
% inserts a colorbar into a figure

% EBSD plot?
if isappdata(gcf,'colorcoding')
  h = findobj(gcf,'type','patch');
  for n = 1:numel(h)
    if size(get(h(n),'FaceVertexCData'),2) == 3
      ebsdColorbar(varargin{:});
      return
    end
  end

elseif isappdata(gcf,'mtexFig')
  mtexFig = getappdata(gcf,'mtexFig');
  mtexFig.colorbar(varargin{:});
else
  [varargout{1:nargout}] = buildinColorbar(varargin{:});
end
