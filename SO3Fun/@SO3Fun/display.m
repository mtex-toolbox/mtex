function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>SO3-function component</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
end

if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end

if SO3F.antipodal, disp('  antipodal: true'); end

disp(['  weight: ' xnum2str(mean(SO3F,'resolution',5*degree))])

disp(' ')

end

