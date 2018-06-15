function h = mtexTitle(s,varargin)
%TITLE Summary of this function goes here
%   Detailed explanation goes here

%s = regexprep(s,'-(\d)','\\bar{$1}');
%s = regexprep(s,'-(\d)','\\bar{$1}');
%s = ['$\mathbf{' s '}$'];

if check_option(varargin,'noTitle'), return; end
varargin = delete_option(varargin,{'position','color'});

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
h = optiondraw(title(ax,s,...
  'interpreter','LaTeX','FontSize',round(getMTEXpref('FontSize')*1.1)),varargin{:});

set(get(ax,'Title'),'Visible','on');

try
  mtexFig = getappdata(get(ax,'Parent'),'mtexFig');
  drawNow(mtexFig,varargin{:});
end

if nargout == 0, clear h; end

end
