function [mtexFig,newFigure] = newMtexFigure(varargin)
% set up a new plotting figure
%
% Syntax
%
%   newMtexFigure('figSize','large')
%   newMtexFigure('layout',[2,3])
%
% Options
%  figSize - huge, large, normal, small, tiny
%  layout  - [numberRows, numberColumns]
%

mtexFig = gcm;

% check hold state
newFigure = isempty(mtexFig) || check_option(varargin,'newFigure') || ...
  (strcmp(getHoldState,'off') && ~check_option(varargin,{'hold','parent','add2all'}) ...
  && ~isempty(get(mtexFig.currentAxes,'Children')));

% check tag
if ~newFigure && check_option(varargin,'ensureTag') && ...
    ~any(strcmpi(get(gcf,'tag'),get_option(varargin,'ensureTag')))
  newFigure = true;
  warning('MTEX:newFigure','Plot type not compatible to previous plot! I''going to create a new figure.');
end

% check appdata
ad = get_option(varargin,'ensureAppdata');
if ~newFigure
  try
    for i = 1:length(ad)
      if isappdata(gcf,ad{i}{1}) && ~isempty(ad{i}{2})
        ad_stored = getappdata(gcf,ad{i}{1});
        if isa(ad{i}{2},'symmetry')
          ad{i}{2} = ad{i}{2}.Laue;
          ad_stored = ad_stored.Laue;
        end
        if ~all(ad_stored == ad{i}{2})
          newFigure = true;
          if ishold
            warning('MTEX:newFigure','Plot properties not compatible to previous plot! I''going to create a new figure.');
          end
          break
        end
      elseif ~isappdata(gcf,ad{i}{1})
        newFigure = true;
        if ishold
          warning('MTEX:newFigure','Plot properties not compatible to previous plot! I''going to create a new figure.');
        end
        break
      end
    end
  catch %#ok<CTCH>
    newFigure = true;
  end
end

% set up a new figure
if newFigure

  if check_option(varargin,'parent')
  
    fig = get_option(varargin,'parent');
    mtexFig.gca = fig;
    while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
      fig = get(fig,'parent');
    end
    mtexFig.parent = fig;
    newFigure = false;
    
  else
    
    mtexFig = mtexFigure(varargin{:});
  
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
  end
else % use an existing figure
  
  % get existing mtexFigure
  mtexFig = getappdata(gcf,'mtexFig');
  
  holdState = getHoldState;
  % distribute hold state over all axes
  for i=1:numel(mtexFig.children)
    hold(mtexFig.children(i),holdState);
  end
  
  % set current axis
  if check_option(varargin,'parent')
    p =  get_option(varargin,'parent');
    if isgraphics(p,'axes')
      mtexFig.currentAxes = p;
    else
      mtexFig.currentAxes = get(p,'parent');
    end
  elseif check_option(varargin,'add2all')
    mtexFig.currentId = 1;
  end
end

if nargout == 0, clear mtexFig; end

end
