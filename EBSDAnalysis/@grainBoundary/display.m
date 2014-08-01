function display(gB,varargin)
% standard output
%
%  id  | mineralLeft | mineralRight
% ---------------------------------
%
% #ids | mineralLeft | mineralRight
% ---------------------------------

disp(' ');
h = doclink('grainBoundary_index','grainBoundary');
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
disp([h ' ' docmethods(inputname(1))])

% empty grain boundary set 
if isempty(gB)
  disp('  grain boundary is empty!')
  return
end

disp(' ')

pairs = allPairs(1:numel(gB.phaseMap));
%pairs(1) = [];

% ebsd.phaseMap
matrix = cell(size(pairs,1),3);


for ip = 1:size(pairs,1)

  num(ip) = nnz(gB.hasPhaseId(pairs(ip,1),pairs(ip,2)));
  matrix{ip,1} = int2str(num(ip));
  
  % phases
  if ischar(gB.CSList{pairs(ip,1)})
    matrix{ip,2} = gB.CSList{pairs(ip,1)};
  else
    matrix{ip,2} = gB.CSList{pairs(ip,1)}.mineral;
  end
  if ischar(gB.CSList{pairs(ip,2)})
    matrix{ip,3} = gB.CSList{pairs(ip,2)};
  else
    matrix{ip,3} = gB.CSList{pairs(ip,2)}.mineral;
  end

end
matrix(num==0,:) = [];


cprintf(matrix,'-L',' ','-Lc',...
  {'Segments' 'mineral 1' 'mineral 2'},'-d','  ','-ic',true);

%disp(' ');
%disp(char(dynProp(gB.prop)));
%disp(' ');
