function display(SO3F,varargin)
% standard output


if check_option(varargin,'skipHeader')
  disp('  <strong>bingham component</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  disp(' ');
end

if SO3F.antipodal, disp('  antipodal: true'); end

disp(['  kappa: ',xnum2str(SO3F.kappa)]);
disp(['  weight: ' xnum2str(mean(SO3F))])
disp(' ');

end
