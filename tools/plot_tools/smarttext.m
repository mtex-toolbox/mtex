function s = smarttext(x,y,s,box,varargin)
% align text smart with respect to the bounding box

arg{1} = 'HorizontalAlignment';
arg{3} = 'VerticalAlignment';

if box(1) + (box(3) - box(1))*2/3 < x
  arg{2} = 'Right';
  x = x - 0.05;
elseif box(1) + (box(3) - box(1))*1/3 < x
  arg{2} = 'Center';
else
  arg{2} = 'Left';
  x = x + 0.05;
end

if box(2) + (box(4) - box(2))*1/3 > y
  arg{4} = 'Bottom';
  y = y + 0.05;
elseif (box(2) + (box(4) - box(2))*2/3 > y) && ~strcmp(arg{2},'Center')
  arg{4} = 'Middle';
else
  arg{4} = 'Top';
  y = y - 0.05;

end

text(x,y,s,varargin{:},arg{:});
