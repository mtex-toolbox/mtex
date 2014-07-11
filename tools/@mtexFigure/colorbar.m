function colorbar(mtexFig,varargin)
      
% remove colorbar if already present
if check_option(varargin,'off') || ...
    ~isempty(findobj(mtexFig.parent,'tag','Colorbar'))
  delete(findobj(mtexFig.parent,'tag','Colorbar'));
  return
end

if strcmp(get(mtexFig.cBarAxis,'zscale'),'log')
  varargin = [{'yscale','log'},varargin];
end

% enlarge current figure
ounits = get(mtexFig.parent,'Units');
set(mtexFig.parent,'Units','pixels');
figSize = get(mtexFig.parent,'Position');

% decide between south and east
if ~check_option(varargin,'log') && (check_option(varargin,'south') || ...
    (any(figSize(4) > mtexFig.axesHeight+10) && ~check_option(varargin,'east')))
  if ~check_option(varargin,'south')
    varargin = [{'south'},varargin];
  end
  figSize(4) = mtexFig.axesHeight+65;
else
  varargin = [{'east'},varargin];
  figSize(4) = mtexFig.axesHeight+1;
  figSize(3) = mtexFig.axesWidth+65;
end

set(mtexFig.parent,'Position',figSize);
set(mtexFig.parent,'Units',ounits);


% set colorrange to equal
cl = get(mtexFig.children,'clim');
if iscell(cl), cl = cell2mat(cl);end
if ~all(equal(cl,1)), setcolorrange('equal'); end

% set correct peer
varargin = delete_option(varargin,'peer',1);
varargin = [{'peer',mtexFig.cBarAxis},varargin];

buildinColorbar(varargin{:})

end
