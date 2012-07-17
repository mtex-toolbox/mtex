function ebsd = find(ebsd,q0,epsilon)
% return a set of EBSD within an epsilon region around q0
%
%% See also
% orientation/find


for k=1:length(ebsd)
  ind = false(size(ebsd(k).orientations));
  for l=1:numel(q0)
    ind = ind | find(ebsd(k).orientations,q0(l),epsilon);
  end
  ebsd(k) = delete(ebsd(k),~ind );
  
end
