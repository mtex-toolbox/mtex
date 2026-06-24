function CSList = ensureCSArray(CSList)
% convert old CSList into new CSArray

if iscell(CSList)
  ind = cellfun(@ischar,CSList);
  CSList(ind) = repcell(notIndexed,1,nnz(ind));
  CSList = [CSList{:}];
end

colors = getMTEXpref('PhaseColorOrder');
cI = 1;
for k = 1:length(CSList)
  if isempty(CSList(k).color) 
    if ~CSList(k).isIndexed 
      CSList(k).color = nan(1,3);
    else
      CSList(k).color = str2rgb(colors(cI));
      cI = cI + 1;
    end
  elseif ischar(CSList(k).color) 
    CSList(k).color = str2rgb(CSList(k).color);
  end
end

end