function h = mtexTitle(s,varargin)
% add a title to an axis or an figure
%
% Syntax
%
%   mtexTitle('title of the current axis')
%   mtexTitle('title of all subplots','global')
%

%s = regexprep(s,'-(\d)','\\bar{$1}');
%s = regexprep(s,'-(\d)','\\bar{$1}');
%s = ['$\mathbf{' s '}$'];

if check_option(varargin,'noTitle'), return; end
varargin = delete_option(varargin,{'position','color'},1);

if ishandle(s)
  ax = s;
  s = varargin{1};
  varargin = varargin(2:end);
else
  ax = gca;
end

%s = ['\bf{IPF $(\mathbf{10\bar{1}1})$ }'];
s = ['\bf{' regexprep(s,'\$([^\$]*)\$','\$\\mathbf{$1}\$') '}'];
s = strrep(s,'$$','');
s = strrep(s,'%','\%');

if check_option(varargin,'global')
  h = optiondraw(sgtitle(s,...
    'interpreter','LaTeX','FontSize',round(getMTEXpref('FontSize')*1.2)),varargin{:});  
else
  h = optiondraw(title(ax,s,...
    'interpreter','LaTeX','FontSize',round(getMTEXpref('FontSize')*1.1)),varargin{:});

  set(get(ax,'Title'),'Visible','on');
end

try
  mtexFig = getappdata(get(ax,'Parent'),'mtexFig');
  drawNow(mtexFig,varargin{:});
end

if nargout == 0, clear h; end

end
