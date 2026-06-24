function str = rgb2str(rgb)
% convert str to rgb values

if ischar(rgb)

  str = rgb;

elseif isstring(rgb)

  str = char(rgb);

elseif any(isnan(rgb))

  str = 'none';

else
  
  str = char(colornames(getMTEXpref('colorPalette','CSS'),rgb));

end