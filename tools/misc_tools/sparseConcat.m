function newSparse = sparseConcat(oldSparse,newRows,newCols,newVals,newSize)

[Si, Sj, Sv] = find(oldSparse); 

%if oldSparse empty, newSparse = newValues
if isempty(Sv)
  
  newSparse = sparse(newRows,newCols,newVals,newSize(1),newSize(2));

%if newValues empty, newSparse = oldSparse
elseif isempty(newVals)

  newSparse = sparse(Si,Sj,Sv,newSize(1),newSize(2));

%if neither empty, newSParse = oldSparse with newVals
else
  
  idx = ismember([Si Sj],[newRows newCols],'rows');
  idx = ~idx;
  newSparse = sparse([Si(idx);newRows],...
    [Sj(idx);newCols],...
    [Sv(idx);newVals],...
    newSize(1),newSize(2));
end
     
