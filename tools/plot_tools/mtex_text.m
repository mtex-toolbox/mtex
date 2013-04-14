function h = mtex_text(x,y,t,varargin)
% insert text depending on mtex preferences

if isempty(t), return;end

interpreter = getMTEXpref('textInterpreter');
fs = getMTEXpref('FontSize');

if isa(t,'vector3d')
  s = char(t,interpreter,'cell');
else

  if ~ischar(t)
    s = char(t);
  else
    s = t;
  end

  if strcmpi(interpreter,'LaTeX') && ~isempty(regexp(s,'[\\\^_]','ONCE'))
    s = ['$' s '$'];
  end

end

h = optiondraw(text(x,y,s,'interpreter',interpreter),'FontSize',fs,varargin{:});
