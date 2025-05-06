function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  SO3-function component"));
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
end

if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end

if SO3F.antipodal, disp('  antipodal: true'); end

if isa(SO3F, 'SO3FunMLS')
  % it is costly to eval the mean of SO3F on other nodes than SO3F.nodes
  disp(['  weight: ' xnum2str(mean(SO3F.values))]); 
else
  disp(['  weight: ' xnum2str(mean(SO3F,'resolution',5*degree))])
end

disp(' ')

end

