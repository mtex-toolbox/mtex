function display(sFs,varargin)
% standard output

displayClass(sFs,inputname(1),'moreInfo',char(sFs.CS,'compact'));

if length(sFs)> 1, disp(['  size: ' size2str(sFs)]);end

disp(['  bandwidth: ' num2str(sFs.bandwidth)]);
if sFs.antipodal, disp('  antipodal: true'); end
if sFs.isReal, disp('  isReal: true'); end
disp(' ');

end
