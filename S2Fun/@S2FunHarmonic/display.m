function display(sF,varargin)
% standard output

% sF.how2plot, not sF.s.how2plot - the convention lives on the function
displayClass(sF,inputname(1),'moreInfo',char(sF.s,'compact',sF.how2plot),varargin{:});

if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

disp(['  bandwidth: ' num2str(sF.bandwidth)]);
if sF.antipodal, disp('  antipodal: true'); end
if ~sF.isReal, disp('  isReal: false'); end
disp(' ');

end
