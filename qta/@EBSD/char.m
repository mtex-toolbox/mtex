function s = char(ebsd)
% ebsd -> char

s = [];
for p = 1:numel(ebsd.phaseMap)
  
  ss = [];
  ss = [ss, 'phase ',num2str(ebsd.phaseMap(p)) ' ']; %#ok<AGROW>
  
  CS = ebsd.CS{p};
  if ischar(CS)
    ss = [ss, '(not Indexed): ' CS ', ']; %#ok<AGROW>
  else
    
    if ~isempty(get(CS,'mineral'))
      ss = [ss, '(' get(CS,'mineral') '): '];
    else
      ss = [ss, ': '];
    end
    
    ss = [ss 'symmetry ' Laue(CS) ', ']; %#ok<AGROW>
  end
  
  ss = [ss, num2str(nnz(ebsd.phaseId == p)),' orientations '];    %#ok<AGROW>
  
  
  s = strvcat(s,ss); %#ok<VCAT>
end
