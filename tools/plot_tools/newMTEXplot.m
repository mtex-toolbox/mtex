function newFigure = newMTEXplot(varargin)
% initalize new plot for MTEX
%
%% Options
%  newFigure
%  newAxis
%  ensureAppdata
%  ensureTag
%  FigureTitle    - figure title to be set for new figures
%
%%
% 


%% check hold state
newFigure = strcmp(getHoldState,'off') ||  check_option(varargin,'newFigure');

%% check tag
if ~newFigure && check_option(varargin,'ensureTag') && ...
  ~any(strcmpi(get(gcf,'tag'),get_option(varargin,'ensureTag')))
  newFigure = true;
  warning('MTEX:newFigure','Plot type not compatible to previous plot! I''m going to create a new figure.');
end

%% check appdata
ad = get_option(varargin,'ensureAppdata');
if ~newFigure
  try
    for i = 1:length(ad)
      if ~isappdata(gcf,ad{i}{1}) || (~isempty(ad{i}{2}) && ~all(getappdata(gcf,ad{i}{1}) == ad{i}{2}))
        newFigure = true;
        warning('MTEX:newFigure','Plot properties not compatible to previous plot! I''going to create a new figure.');
        break
      end
    end
  catch %#ok<CTCH>
    newFigure = true;
  end
end


if ~newFigure, return;end

%% new figure
clf('reset');
rmallappdata(gcf);

iconMTEX(gcf);
MTEXFigureMenu(varargin{:});

% set tag
if check_option(varargin,'ensureTag','char')
  set(gcf,'tag',get_option(varargin,'ensureTag'));
end

% set appdata
if check_option(varargin,'ensureAppdata')
  for i = 1:length(ad)
    setappdata(gcf,ad{i}{1},ad{i}{2})
  end
end

% set figure name
if ~isempty(get_option(varargin,'FigureTitle'))
  set(gcf,'Name',get_option(varargin,'FigureTitle'));
end

old_units = get(gcf,'units');
set(gcf,'units','pixel');

varargin = delete_option(varargin,'color',1);

optiondraw(gcf,varargin{:});
set(gcf,'units',old_units);


