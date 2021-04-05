function display(SO3F,varargin)
% called by standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>unimodal component</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
end

disp(['  kernel: ',char(SO3F.psi)]);
if isa(SO3F.center,'SO3Grid')
  disp(['  center: ',char(SO3F.center)]);
else
  disp(['  center: ',num2str(length(SO3F.center)) ' orientations']);
  Euler(SO3F.center)
end
if SO3F.c0 > 0, disp(['      c0: ',xnum2str(SO3F.c0)]); end

end
