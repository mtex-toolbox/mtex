function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>function handle component</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
end

if length(SO3F) > 1, disp([' size: ' size2str(SO3F)]); end
disp(['  weight: ' num2str(mean(SO3F(1),'all','bandwidth',16))])
disp(' ')

end
