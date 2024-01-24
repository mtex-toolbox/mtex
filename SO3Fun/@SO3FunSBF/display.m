function display(SO3F,varargin)
% called by standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>structural basis function</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  if SO3F.antipodal, disp('  antipodal: true'); end
  disp(' ');
end

disp(['    slip system: ',char(SO3F.sS.n),char(SO3F.sS.b)]);
disp(['    strain:      ',xnum2str(double(diag(SO3F.E)))]);

end
