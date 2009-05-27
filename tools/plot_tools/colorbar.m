function cb = colorbar(varargin)
% inserts a colorbar into a figure

%% EBSD plot?
if strcmpi(get(gcf,'tag'),'ebsd_spatial') && isappdata(gcf,'r')
  ebsdColorbar
  return
end

if isappdata(gcf,'axes')
  cax = getappdata(gcf,'colorbaraxis');

  
  if strcmp(get(cax,'zscale'),'log')
    varargin = {'yscale','log',varargin{:}};
  end

  ounits = get(gcf,'Units');
  set(gcf,'Units','pixels');
  fpos = get(gcf,'Position');
  apos = get(gcf,'UserData');

  if ~isempty(findobj(gcf,'tag','Colorbar'))

    if ~check_option(varargin,'off')
      varargin = {varargin{:},'off'};
    end
    fpos(4) = apos(2)+1;
    fpos(3) = apos(1)+1;

  else

    if ~check_option(varargin,'log') && (check_option(varargin,'south') || ...
        (fpos(4) > apos(2)+5 && ~check_option(varargin,'east')))
      if ~check_option(varargin,'south')
        varargin = {'south',varargin{:}};
      end
      fpos(4) = apos(2)+65;
    else
      varargin = {'east',varargin{:}};
      fpos(4) = apos(2)+1;
      fpos(3) = apos(1)+65;
    end

  end
  set(gcf,'Position',fpos);
  set(gcf,'Units',ounits);


  
  % check whether colorrange has to be set equal
  ax = findall(gcf,'type','axes','tag','S2Grid');

  cl = get(ax,'clim');
  if iscell(cl), cl = cell2mat(cl);end
  if ~all(equal(cl,1)), setcolorrange('equal'); end
  
  varargin = delete_option(varargin,'peer',1);  
  varargin = {'peer',cax,varargin{:}};
end

% locate default colorbar
s = which('colorbar','-all');
pathstr = fileparts(s{end});
opwd = pwd;
cd(pathstr);

if ~check_option(varargin,'off') && nargout
  cb = colorbar(varargin{:});
else
  colorbar(varargin{:});
end

cd(opwd);
