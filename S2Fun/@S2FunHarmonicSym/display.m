function display(sFs,varargin)
% standard output

displayClass(sFs,inputname(1),'moreInfo',char(sFs.CS,'compact'));

if length(sFs)> 1, disp(['  size: ' size2str(sFs)]);end

% display symmetry
if isa(sFs.s,'crystalSymmetry')
  if isempty(sFs.CS.mineral)
    disp(['  symmetry: ',char(sFs.CS,'verbose')]);
  else
    disp(['  mineral: ',char(sFs.CS,'verbose')]);
  end
else
    disp(['  symmetry: ',char(sFs.SS)]);
end

disp(['  bandwidth: ' num2str(sFs.bandwidth)]);
if sFs.antipodal, disp('  antipodal: true'); end
if sFs.isReal, disp('  isReal: true'); end
disp(' ');

end
