function ebsd = find(ebsd,q0,epsilon)


for k=1:length(ebsd)
  
  ebsd(k) = delete(ebsd(k), ~find(ebsd(k).orientations,q0,epsilon));
  
end
