function display(SO3F,varargin)
% called by standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>unimodal component</strong>');
else
  displayClass(SO3F,inputname(1),varargin{:});
end

disp(['  kernel: ',char(SO3F.psi)]);
disp(['  center: ',char(SO3F.center)]);
if SO3F.c0 > 0, disp(['      c0: ',xnum2str(SO3F.c0)]); end

end
