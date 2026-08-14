function display(sFs,varargin)
% standard output

% sFs.how2plot, not sFs.CS.how2plot - the convention lives on the function
displayClass(sFs,inputname(1),'moreInfo',char(sFs.CS,'compact',sFs.how2plot));

if length(sFs)> 1, disp(['  size: ' size2str(sFs)]);end

disp(['  bandwidth: ' num2str(sFs.bandwidth)]);
if sFs.antipodal, disp('  antipodal: true'); end
if ~sFs.isReal, disp('  isReal: false'); end
disp(' ');

end
