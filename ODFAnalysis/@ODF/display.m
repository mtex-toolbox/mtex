function display(odf,varargin)
% standard output

if isempty(odf)
  
  displayClass(odf,inputname(1));
  return
    
elseif isa(odf.SS,'crystalSymmetry') && isa(odf.CS,'crystalSymmetry')  
  displayClass(odf,inputname(1),'MDF');  
else  
  displayClass(odf,inputname(1));  
end

% display symmtries and minerals
if ~isempty(odf.CS), disp(char(odf.CS,'verbose','symmetryType'));end
if ~isempty(odf.SS) && odf.SS.id>1, disp(char(odf.SS,'verbose','symmetryType'));end
if odf.antipodal, disp('  antipodal:         true'); end

% display components
disp(' ');
for i = 1:length(odf.components)
  
  odf.components{i}.display;
  disp(['    weight: ',num2str(odf.weights(i))]);  
  disp(' ');
  
end
