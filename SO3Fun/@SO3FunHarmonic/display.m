function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>harmonic component</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  if SO3F.antipodal, disp('  antipodal: true'); end
  if SO3F.isReal, disp('  isReal: true'); end
  if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end
end

disp(['  bandwidth: ' num2str(SO3F.bandwidth)]);
disp(['  weight: ' xnum2str(mean(SO3F.subSet(1)))]);
disp(' ');

end
