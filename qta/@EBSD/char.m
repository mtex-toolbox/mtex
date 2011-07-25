function s = char(ebsd)
% ebsd -> char

s = [];
for p = unique(ebsd.phases)'
  
  ss = [];
  ss = [ss, 'phase ',num2str(p) ': ']; %#ok<AGROW>
      
  CS = ebsd.CS{p};
  if ~isempty(get(CS,'mineral'))
    ss = [ss, get(CS,'mineral') ', ']; %#ok<AGROW>
  end    
  
  ss = [ss, num2str(nnz(ebsd.phases == p)),' orientations, '];    %#ok<AGROW>
    
  ss = [ss,'symmetry: ',Laue(CS)];     %#ok<AGROW>
  
  s = strvcat(s,ss); %#ok<VCAT>
end
