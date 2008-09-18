function s = smarttext(x,y,s,box,varargin)
% align text smart with respect to the bounding box

arg{1} = 'HorizontalAlignment';
arg{3} = 'VerticalAlignment';
if check_option(varargin,'BackgroundColor'), delta = 0.1; else delta = 0; end

if box(1) + (box(3) - box(1))*2/3 < x
  arg{2} = 'Right';
  x = x - delta;
elseif box(1) + (box(3) - box(1))*1/3 < x
  arg{2} = 'Center';
else
  arg{2} = 'Left';
  x = x + delta;
end

if box(2) + (box(4) - box(2))*1/3 > y
  arg{4} = 'Bottom';
  y = y + delta;
elseif (box(2) + (box(4) - box(2))*2/3 > y) && ~strcmp(arg{2},'Center')
  arg{4} = 'Middle';
else
  arg{4} = 'Top';
  y = y - delta;

end

mtex_text(x,y,s,arg{:},varargin{:});
