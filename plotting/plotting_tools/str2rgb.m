function rgb = str2rgb(str)
% convert str to rgb values

if nargin == 0
  rgb = ['none';'flat';colornames(getMTEXpref('colorPalette','CSS'))];
  return;
end

% replace shortcuts by long color names
if ischar(str) && length(str)==1
  longNames = {'red','green','blue','yellow','cyan','black','white','magenta'};
  shortNames = {'r','g','b','y','c','k','w','m'};
  str = longNames{strcmpi(str,shortNames)};
end


oldNames = {'light blue','light green','light red',...
  'dark blue','dark green','dark red','Amethyst'};

oldColors = {[0.5 0.5 1],[0.5 1 0.5],[1 0.5 0.5],...
  [0 0 0.3],[0 0.3 0],[0.3 0 0],[0.2344 0.6992 0.4414]};

if isnumeric(str)
  
  rgb = str;
  
elseif any(strcmpi(str,{'none','flat'}))

  rgb = str;

else
  
  try % for compatibility
    rgb = oldColors{strcmpi(str,oldNames)};  
  catch  
    [~,rgb] = colornames(getMTEXpref('colorPalette','CSS'),str);
  end

end