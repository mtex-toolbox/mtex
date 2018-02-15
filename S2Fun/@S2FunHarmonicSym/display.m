function display(sFs,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S2FunHarmonic_index','S2FunHarmonic') ...
    ' ' docmethods(inputname(1))]);
end

if length(sFs)> 1, disp([' size: ' size2str(sFs)]);end

% display symmetry
if isa(sFs.s,'crystalSymmetry')
  if isempty(sFs.CS.mineral)
    disp([' symmetry: ',char(sFs.CS,'verbose')]);
  else
    disp([' mineral: ',char(sFs.CS,'verbose')]);
  end
else
    disp([' symmetry: ',char(sFs.SS)]);
end

disp([' bandwidth: ' num2str(sFs.bandwidth)]);
if sFs.antipodal, disp(' antipodal: true'); end

end
