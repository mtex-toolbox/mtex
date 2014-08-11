function s = char(ebsd)
% ebsd -> char

s = [];
for p = 1:numel(ebsd.phaseMap)
  
  ss = [];
  ss = [ss, 'phase ',num2str(ebsd.phaseMap(p)) ' ']; %#ok<AGROW>
  
  CS = ebsd.CSList{p};
  if ischar(CS)
    ss = [ss, '(not Indexed): ' CS ', ']; %#ok<AGROW>
  else
    
    if ~isempty(CS.mineral)
      ss = [ss, '(' CS.mineral '): ']; %#ok<AGROW>
    else
      ss = [ss, ': ']; %#ok<AGROW>
    end
    
    ss = [ss 'symmetry ' CS.pointGroup ', ']; %#ok<AGROW>
  end
  
  ss = [ss, num2str(nnz(ebsd.phaseId == p)),' orientations '];    %#ok<AGROW>
  
  
  s = strvcat(s,ss);
end
