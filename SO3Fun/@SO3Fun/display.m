function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>SO3-function component</strong>');
else
  displayClass(SO3F,inputname(1),varargin{:});
end

if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end
disp(['  weight: ' xnum2str(mean(SO3F(1),'all','bandwidth',16))])
end
