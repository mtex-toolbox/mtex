function display(sF,varargin)
% standard output

% a symmetrised function is named by the group it is invariant under, any
% other by its frame - and sF.how2plot in both cases, since the convention
% lives on the function
sym = getSym(sF);
if isempty(sym)
  info = referenceFrame.headerChar(sF.frame,sF.how2plot);
else
  info = char(sym,'compact',sF.how2plot);
end

displayClass(sF,inputname(1),'moreInfo',info,varargin{:});

if length(sF) > 1, disp(['  size: ' size2str(sF)]); end

disp(['  bandwidth: ' num2str(sF.bandwidth)]);
if sF.antipodal, disp('  antipodal: true'); end
if ~sF.isReal, disp('  isReal: false'); end
disp(' ');

end
