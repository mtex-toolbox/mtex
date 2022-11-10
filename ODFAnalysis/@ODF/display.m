function display(odf,varargin)
% standard output

if isempty(odf.CS)  
  displayClass(odf,inputname(1));
  return    
end

refSystems = [char(odf.CS,'compact') ' ' getMTEXpref('arrowChar') ' ' char(odf.SS,'compact')];

if isa(odf.SS,'crystalSymmetry') && isa(odf.CS,'crystalSymmetry')
  type = 'MDF';
else
  type = 'ODF';
end
displayClass(odf,inputname(1),'className',type,'moreInfo',refSystems);


% display symmtries and minerals
if odf.antipodal, disp('  antipodal:         true'); end

% display components
disp(' ');
for i = 1:length(odf.components)
  
  odf.components{i}.display;
  disp(['    weight: ',num2str(odf.weights(i))]);  
  disp(' ');
  
end
