function display(sF,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S2FunHarmonic_index','S2FunHarmonic') ...
    ' ' docmethods(inputname(1))]);
end

if length(sF) > 1, disp([' size: ' size2str(sF)]); end
disp([' bandwidth: ' num2str(sF.bandwidth)]);
if sF.antipodal, disp(' antipodal: true'); end

end
