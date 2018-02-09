function display(sAF,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S2AxisFieldHarmonic_index','S2AxisFieldHarmonic') ...
    ' ' docmethods(inputname(1))]);
end

disp([' bandwidth: ' num2str(sAF.sF.bandwidth)]);

if sAF.sF.antipodal, disp(' antipodal: true'); end

end
