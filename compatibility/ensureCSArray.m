function CSList = ensureCSArray(CSList)
% convert old CSList into new CSArray

if iscell(CSList)
  ind = cellfun(@ischar,CSList);
  CSList(ind) = repcell(notIndexed,1,nnz(ind));
  CSList = [CSList{:}];
end

% phases that share a mineral name, in any case, and phases without one
% take a number each in their order - Iron 1, Iron 2 - so that every phase
% can be addressed by its name; a name given once stays
isInd = find(arrayfun(@(cs) cs.isIndexed, CSList));
names = arrayfun(@(cs) strtrim(char(cs.mineral)), CSList(isInd), 'UniformOutput', false);
taken = lower(names);
[u,~,g] = unique(taken,'stable');
for j = 1:numel(u)
  ind = find(g == j);
  if isscalar(ind), continue; end
  k = 1;
  for i = ind(:).'
    % a number another phase already has as its name is passed over
    newName = strtrim([names{i} ' ' num2str(k)]); k = k + 1;
    while ismember(lower(newName),taken)
      newName = strtrim([names{i} ' ' num2str(k)]); k = k + 1;
    end
    taken{end+1} = lower(newName); %#ok<AGROW>
    % a symmetry is a handle and its frame carries the name too: the phase
    % takes copies of both, the symmetry it was given keeps its name
    cs = copy(CSList(isInd(i)));
    cs.frame = copy(cs.frame);
    cs.mineral = newName;
    cs.frame.name = newName;
    CSList(isInd(i)) = cs;
  end
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
