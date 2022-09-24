function display(sFs,varargin)
% standard output

displayClass(sFs,inputname(1),'S2FunHarmonicSym','moreInfo',char(sFs.CS,'compact'));

%displayClass(sFs,inputname(1),varargin{:});

if length(sFs)> 1, disp([' size: ' size2str(sFs)]);end

disp([' bandwidth: ' num2str(sFs.bandwidth)]);
if sFs.antipodal, disp(' antipodal: true'); end

end
