function display(tP,varargin)
% standard output
%
%  id  | mineralLeft | mineralRight
% ---------------------------------
%
% #ids | mineralLeft | mineralRight
% ---------------------------------

disp(' ');
h = doclink('tripelPointList_index','tripelPointList');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
disp([h ' ' docmethods(inputname(1))])

% empty grain boundary set 
if isempty(tP)
  disp('  grain boundary is empty!')
  return
end

disp(' ')

tripel = allTripel(1:numel(tP.phaseMap));

% ebsd.phaseMap
matrix = cell(size(tripel,1),4);


for ip = 1:size(tripel,1)

  num(ip) = nnz(tP.hasPhaseId(tripel(ip,1),tripel(ip,2),tripel(ip,3))); %#ok<AGROW>
  matrix{ip,1} = int2str(num(ip));
  
  % phases
  if ischar(tP.CSList{tripel(ip,1)})
    matrix{ip,2} = tP.CSList{tripel(ip,1)};
  else
    matrix{ip,2} = tP.CSList{tripel(ip,1)}.mineral;
  end
  if ischar(tP.CSList{tripel(ip,2)})
    matrix{ip,3} = tP.CSList{tripel(ip,2)};
  else
    matrix{ip,3} = tP.CSList{tripel(ip,2)}.mineral;
  end
  
  if ischar(tP.CSList{tripel(ip,3)})
    matrix{ip,4} = tP.CSList{tripel(ip,3)};
  else
    matrix{ip,4} = tP.CSList{tripel(ip,3)}.mineral;
  end

end
matrix(num==0,:) = [];


cprintf(matrix,'-L',' ','-Lc',...
  {'points' 'mineral 1' 'mineral 2' 'mineral 2'},'-d','  ','-ic',true);

%disp(' ');
%disp(char(dynProp(gB.prop)));
%disp(' ');
