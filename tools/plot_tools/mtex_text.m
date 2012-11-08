function h = mtex_text(x,y,t,varargin)
% insert text depending on mtex preferences

if isa(t,'Miller') || isa(t,'vector3d')
  for i = 1:length(t)
    if getpref('mtex','LaTex')
      s{i} = ['$' char(t(i),'LaTex') '$']; %#ok<AGROW>
    else
      s{i} = char(t(i),'Tex'); %#ok<AGROW>
    end
  end
else
  if ~ischar(t)
    s = char(t);
  else
    s = t;
  end
  if getpref('mtex','LaTex') && ~isempty(regexp(s,'[\\\^_]','ONCE'))
    s = ['$' s '$'];
  end
end
if ~getpref('mtex','LaTex')
  h = optiondraw(text(x,y,s,'interpreter','tex'),varargin{:});
elseif ~isempty(t)
  h = optiondraw(text(x,y,s,'interpreter','latex'),varargin{:});
end
