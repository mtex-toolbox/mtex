function str = rgb2str(rgb)
% convert str to rgb values

if ischar(rgb)

  str = rgb;

else
  
  str = char(colornames(getMTEXpref('colorPalette','CSS'),rgb));

end