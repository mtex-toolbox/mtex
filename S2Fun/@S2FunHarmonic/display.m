function display(sF,varargin)
% standard output

displayClass(sF,inputname(1),'moreInfo',char(sF.s,'compact'),varargin{:});

if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

disp(['  bandwidth: ' num2str(sF.bandwidth)]);
if sF.antipodal, disp('  antipodal: true'); end
if ~sF.isReal, disp('  isReal: false'); end
disp(' ');

end
