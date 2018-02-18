function display(sVF,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S2VectorFieldHarmonic_index','S2VectorFieldHarmonic') ...
    ' ' docmethods(inputname(1))]);
end

disp([' bandwidth: ' num2str(sVF.sF.bandwidth)]);

if sVF.sF.antipodal, disp(' antipodal: true'); end

end
