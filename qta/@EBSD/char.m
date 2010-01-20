function s = char(ebsd)
% ebsd -> char

s = [];
for i = 1:length(ebsd)
  
  ss = [];
  if ~isempty(ebsd(i).phase)
    ss = [ss, 'phase ',num2str(ebsd(i).phase(1)) ': ']; %#ok<AGROW>
  end
    
  if ~isempty(get(ebsd(i).CS,'mineral'))
    ss = [ss, get(ebsd(i).CS,'mineral') ', ']; %#ok<AGROW>
  end    
  
  if ~isempty(ebsd(i).orientations)
    ss = [ss, num2str(numel(ebsd(i).orientations)),' orientations, '];    %#ok<AGROW>
  end
  
  ss = [ss,'symmetry: ',char(ebsd(i).CS)];     %#ok<AGROW>
  
  s =strvcat(s,ss); %#ok<VCAT>
end
