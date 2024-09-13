function display(o)
% standard output

refSystems = [char(o.CS,'compact') ' ' getMTEXpref('arrowChar') ' ' char(o.SS,'compact')];

if isMisorientation(o)  
  type = 'misorientation';
else
  type = 'orientation';
end
displayClass(o,inputname(1),'className',type,'moreInfo',refSystems);

%disp(char(o.CS,'verbose','symmetryType'));
%if o.SS.id ~= 1, disp(char(o.SS,'verbose','symmetryType')); end
%disp(['  ' char(o.CS,'compact') ' <strong>' char(8594) '</strong> ' char(o.SS,'compact')] );
%disp(['  ' char(o.CS,'compact') ' 🠖 ⟶ ➞ ' char(o.SS,'compact')] );
%disp(['  ' char(o.CS,'compact') ' ' char([55358 56342]) ' ' char(o.SS,'compact')] );

if length(o)~=1, disp(['  size: ' size2str(o)]); end

if o.antipodal
  disp('  antipodal:         true');
end
  
if isMisorientation(o) && isscalar(o) && angle(o,round2Miller(o))<1e-3
  
  disp(' ');
  %disp('     planes      directions');
  disp([' ',char(o)]);
  disp(' ')

elseif length(o) < 20 && ~isempty(o)
  Euler(o);
elseif ~getMTEXpref('generatingHelpMode') && ~isempty(o)
  disp(' ')
  s = setappdata(0,'data2beDisplayed',o);
  disp(['  <a href="matlab:Euler(getappdata(0,''',s,'''))">show Euler angles</a>'])
  disp(' ')
end
