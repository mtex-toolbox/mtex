function ind = squareNeighbors(RowsCols,Nid,varargin)
% return the neighbor ids in a square grid
%
%

[col,row] = meshgrid(1:RowsCols(2),1:RowsCols(1));

order = get_option(varargin,'order',0);
if order == 0
  dRow = [0 1 0 -1];
  dCol = [1 0 -1 0];
else
  [dRow,dCol] = meshgrid(-order:order);
  dRow(2*order^2+2*order+1) = [];
  dCol(2*order^2+2*order+1) = [];
end

if nargin >= 2 && ~isempty(Nid)
  ind = calcInd(Nid);
else
  
  ind = zeros([RowsCols,length(dRow)]);
  for Nid = 1:length(dRow)
    ind(:,:,Nid) = calcInd(Nid);
  end
  
end

  function indLocal = calcInd(Nid)
  
  nrow = row + dRow(Nid);
  ncol = col + dCol(Nid);
  
  % ensure coordinates are within the range
  if check_option(varargin,'strict')

    indLocal = zeros(size(nrow));
    isInside = ~(ncol<1 | ncol>RowsCols(2) | nrow<1 | nrow>RowsCols(1));

    indLocal(isInside) = sub2ind(RowsCols,nrow(isInside),ncol(isInside));

  else
    ncol = max(min(ncol,RowsCols(2)),1);
    nrow = max(min(nrow,RowsCols(1)),1);

    indLocal = sub2ind(RowsCols,nrow,ncol);
  end


  
  
  end
  
end