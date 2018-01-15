function display(sFs,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S2FunHarmonic_index','S2FunHarmonic') ...
    ' ' docmethods(inputname(1))]);
end

disp([' size: ' size2str(sFs)]);
disp([' bandwidth: ' num2str(sFs.bandwidth)]);
disp([' symmetrie: ' sFs.s.LaueName]);

if sFs.antipodal, disp(' antipodal: true'); end

end
