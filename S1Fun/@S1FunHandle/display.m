function display(sF,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  function handle component"));
else
  displayClass(sF,inputname(1),varargin{:});
  if length(sF) > 1, disp(['  size: ' size2str(sF)]); end
end

if sF.antipodal, disp('  antipodal: true'); end

disp(['  eval: ' char(sF.fun)]);

disp(' ');

end