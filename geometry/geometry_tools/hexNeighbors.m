function ind = hexNeighbors(RowsCols,Nid)
% return the neighbor ids in a hex grid
%
%

[col,row] = meshgrid(1:RowsCols(2),1:RowsCols(1));

dRow = [0 1 1 0 -1 -1];
dColEven = [1 1 0 -1 0 1];
dColOdd = [1 0 -1 -1 -1 0];

if nargin == 2
  ind = calcInd(Nid);
else
  
  ind = zeros([RowsCols,6]);
  for Nid = 1:6
    ind(:,:,Nid) = calcInd(Nid);
  end
  
end
 
  function indLocal = calcInd(Nid)
  
  nrow = row + dRow(Nid);
  ncol = col + dColEven(Nid) * iseven(row)  + dColOdd(Nid) * ~iseven(row);
  
  % ensure coordinates are within the range
  ncol = max(min(ncol,RowsCols(2)),1);
  nrow = max(min(nrow,RowsCols(1)),1);

  indLocal = sub2ind(RowsCols,nrow,ncol);
  
  end
  
end