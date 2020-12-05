function display(o)
% standart output

if ~isa(o.SS,'symmetry') || ~isa(o.CS,'symmetry')
  displayClass(o,inputname(1),'invalid orientation');
  disp([' size: ' size2str(o)]);
  return
elseif isMisorientation(o)  
  displayClass(o,inputname(1),'misorientation');
elseif isa(o.SS,'crystalSymmetry')
  displayClass(o,inputname(1),'inverse orientation');
else
  displayClass(o,inputname(1));
end

if length(o)~=1, disp(['  size: ' size2str(o)]); end
disp(char(o.CS,'verbose','symmetryType'));
if o.SS.id ~= 1, disp(char(o.SS,'verbose','symmetryType')); end

if o.antipodal
  disp('  antipodal:         true');
end
  

if length(o) < 20 && ~isempty(o)
  Euler(o);
elseif ~getMTEXpref('generatingHelpMode')
  disp(' ')
  setappdata(0,'data2beDisplayed',o);
  disp('  <a href="matlab:Euler(getappdata(0,''data2beDisplayed''))">show Euler angles</a>')
  disp(' ')
end
