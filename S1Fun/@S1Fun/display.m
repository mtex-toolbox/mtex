function display(sF,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  S1-function component"));
else
  displayClass(sF,inputname(1),varargin{:});
end

if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

if sF.antipodal, disp('  antipodal: true'); end

disp(['  weight: ' xnum2str(mean(sF,'resolution',5*degree))])

disp(' ')

end

