function [mP,isNew] = newMapPlot(varargin)
% 
%

isNew = true;

% case 1: predefined axis
% -----------------------
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
  
  % axis is already a map plot
  if isappdata(ax,'mapPlot') && ishold(ax)
  
    mP = getappdata(ax,'mapPlot');
    isNew = false;
    
  else % set up new axes if required
    
    % create a new map plot
    mP = mapPlot(ax,varargin{:});
            
  end
else

  % create a new mtexFigure or get a reference to it
  mtexFig = newMtexFigure(varargin{:});
  mtexFig.keepAspectRatio = false;
  
  % create a new map plot
  mP = mapPlot(mtexFig.gca,varargin{:});
  
end
  
end
