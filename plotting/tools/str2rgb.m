function rgb = str2rgb(str)
% convert str to rgb values

if isnumeric(str)
  rgb = str;
elseif any(strcmpi(str,{'blue','red','black','white','green','yellow',...
    'cyan','magenta','b','r','k','w','g','y','c','m','none','flat'}))

  rgb = str;

else
  
  [~,rgb] = colornames(getMTEXpref('colorPalette','CSS'),str);

end