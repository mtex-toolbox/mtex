function varargout = mtexTitle(s,varargin)
%TITLE Summary of this function goes here
%   Detailed explanation goes here

%s = regexprep(s,'-(\d)','\\bar{$1}');
%s = regexprep(s,'-(\d)','\\bar{$1}');
%s = ['$\mathbf{' s '}$'];

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
[varargout{1:nargout}] = title(ax,s,...
  'interpreter','LaTeX','FontSize',round(getMTEXpref('FontSize')*1.1),varargin{:});

set(get(ax,'Title'),'Visible','on');

end

