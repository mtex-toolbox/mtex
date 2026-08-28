function display(SO3F,varargin)
% called by standard output

if check_option(varargin,'skipHeader')
  disp(strong("  fibre component"));
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  if SO3F.antipodal, disp('  antipodal: true'); end
  disp(' ');
end

disp(['  kernel: ',char(SO3F.psi)]);
% the component is pinned by the one crystal direction it holds parallel to r
disp(['  fibre : ',char(stripSym(round(SO3F.h))),' || ' char(round(SO3F.r))]);
disp(['  weight: ',xnum2str(mean(SO3F))]);
disp(' ');

end
