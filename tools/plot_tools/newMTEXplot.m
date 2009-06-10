function newFigure = newMTEXplot(varargin)
% initalize new plot for MTEX
%
%% 
%% Options
%  newFigure
%  newAxis
%  ensureAppdata
%  ensureTag
% 
%
%%
% 


%% new figure

if ~ishold ||  check_option(varargin,'newFigure') %(nargin == 0) ||
  newFigure = true;
else
  newFigure = false;
end


%% check tag
if check_option(varargin,'ensureTag')
  newFigure = newFigure  || ...
    ~any(strcmpi(get(gcf,'tag'),get_option(varargin,'ensureTag')));
end

%% check appdata
if check_option(varargin,'ensureAppdata')
  ad = get_option(varargin,'ensureAppdata');
  try
    for i = 1:length(ad)
      if ~(getappdata(gcf,ad{i}{1}) == ad{i}{2})
        newFigure = true;
      end
    end
  catch %#ok<CTCH>
    newFigure = true;
  end
end


if newFigure  
  clf('reset');
  figure(clf);
  rmallappdata(gcf);  
  
	try
  	jframe=get(gcf,'javaframe');
    jIcon=javax.swing.ImageIcon(fullfile(mtex_path,'mtex_icon.gif'));
    jframe.setFigureIcon(jIcon);
  catch
	end
end
