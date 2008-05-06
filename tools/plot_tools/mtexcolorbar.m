function cb = mtexcolorbar(varargin)
% inserts a colorbar into a figure

if strcmp(get(gcf,'tag'),'multiplot')
  ax = getappdata(gcf,'colorbaraxis');
  varargin = {varargin{:},'peer',ax};
  if strcmp(get(ax,'zscale'),'log')
    varargin = {varargin{:},'yscale','log'};
  end
  
  % check whether colorrange has to be set equal
  ax = findall(gcf,'type','axes','tag','S2Grid');

  cl = get(ax,'clim');
  if iscell(cl), cl = cell2mat(cl);end
  if ~all(equal(cl,1)), setcolorrange('equal'); end
  
end

if ~check_option(varargin,'off') && nargout
  cb = colorbar(varargin{:});
else
  colorbar(varargin{:});
end
