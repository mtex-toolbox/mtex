function rgb = str2rgb(str)
% convert str to rgb values

oldNames = {'light blue','light green','light red',...
  'dark blue','dark green','dark red','Amethyst'};

oldColors = {[0.5 0.5 1],[0.5 1 0.5],[1 0.5 0.5],...
  [0 0 0.3],[0 0.3 0],[0.3 0 0],[0.2344 0.6992 0.4414]};

if isnumeric(str)
  
  rgb = str;
  
elseif any(strcmpi(str,{'blue','red','black','white','green','yellow',...
    'cyan','magenta','b','r','k','w','g','y','c','m','none','flat'}))

  rgb = str;

else
  
  try % for compatibility
    rgb = oldColors{strcmpi(str,oldNames)};  
  catch  
    [~,rgb] = colornames(getMTEXpref('colorPalette','CSS'),str);
  end

end