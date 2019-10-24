function h = text3(v,varargin)
% plot three dimensional arrows
%
% Syntax
%   text3(v,string)
%
% Input
%
% See also
% savefigure vector3d/scatter3 vector3d/plot3 vector3d/arrow3

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

scaling = get_option(varargin,'scaling',1.2);
v = scaling.*v;

if check_option(varargin,'labeled')
  strings = cell(1,length(v));
  for i = 1:length(v)
    strings{i} = char(v.subSet(i),getMTEXpref('textInterpreter')); 
  end
else
  strings = ensurecell(varargin{1});
  if length(v)>1 && length(strings)==1
    strings = repmat(strings,length(v),1);
  end
end

for i = 1:length(v)
  h = optiondraw(text(v.x(i),v.y(i),v.z(i),strings{i},'FontSize',15,'parent',ax,'interpreter','LaTeX'),...
    'horizontalAlignment','center','verticalAlignment','middle',varargin{:});
end

% set axis to 3d
%axis(ax,'equal','vis3d','off');

% st box limits
%bounds = [-1.2,1.2] * max(norm(v(:)));
%set(ax,'XDir','rev','YDir','rev','XLim',bounds,'YLim',bounds,'ZLim',bounds);

if nargout == 0, clear h;end
