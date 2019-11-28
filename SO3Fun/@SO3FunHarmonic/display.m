function display(F,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('SO3FunHarmonic_index','SO3FunHarmonic') ...
    ' ' docmethods(inputname(1))]);
end

if length(F) > 1, disp([' size: ' size2str(F)]); end
disp([' bandwidth: ' num2str(F.bandwidth)]);

end
