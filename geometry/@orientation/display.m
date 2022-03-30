function display(o)
% standart output

refSystems = [char(o.CS,'compact') ' ' char(8594) ' ' char(o.SS,'compact')];

if isMisorientation(o)  
  type = 'misorientation';
else
  type = 'orientation';
end
displayClass(o,inputname(1),type,'moreInfo',refSystems);

%disp(char(o.CS,'verbose','symmetryType'));
%if o.SS.id ~= 1, disp(char(o.SS,'verbose','symmetryType')); end
%disp(['  ' char(o.CS,'compact') ' <strong>' char(8594) '</strong> ' char(o.SS,'compact')] );
%disp(['  ' char(o.CS,'compact') ' 🠖 ⟶ ➞ ' char(o.SS,'compact')] );
%disp(['  ' char(o.CS,'compact') ' ' char([55358 56342]) ' ' char(o.SS,'compact')] );

if length(o)~=1, disp(['  size: ' size2str(o)]); end

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
