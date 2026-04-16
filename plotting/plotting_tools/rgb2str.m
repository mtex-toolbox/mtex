function str = rgb2str(rgb)
% convert str to rgb values

if ischar(rgb)

  str = rgb;

elseif isstring(rgb)

  str = char(rgb);

else
  
  str = char(colornames(getMTEXpref('colorPalette','CSS'),rgb));

end