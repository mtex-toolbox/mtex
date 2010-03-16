function ebsd = find(ebsd,q0,epsilon)


for k=1:length(ebsd)
  ind = false(size(ebsd(k).orientations));
  for l=1:numel(q0)
    ind = ind | find(ebsd(k).orientations,q0(l),epsilon);
  end
  ebsd(k) = delete(ebsd(k),~ind );
  
end
