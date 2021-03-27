function ind = subsind(gB,subs)

% select by isIndexed
if check_option(subs,'indexed')
  ind = gB.isIndexed;
  subs = delete_option(subs,'indexed');
else
  ind = true(length(gB),1);
end

% select by CS
phaseId = cellfun(@gB.cs2phaseId,subs);
if any(phaseId)
  tmp = vec2cell(phaseId(phaseId>0));
  ind = gB.hasPhaseId(tmp{:});
end
subs = subs(~phaseId);

% select for grains
isGrain = cellfun(@(x) isa(x,'grain2d'),subs);
if any(isGrain)
  ind = ind & gB.hasGrain(subs{isGrain});
end
subs = subs(~isGrain);

% other indexing
for i = 1:length(subs)
         
  if isa(subs{i},'logical')
    
    sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind & reshape(sub,size(ind));
    
  elseif isnumeric(subs{i})
    
    if any(subs{i} <= 0 | subs{i} > length(gB))
      error('Out of range; index must be a positive integer or logical.')
    end
    
    ind = subs{i};
    return
    
  elseif isa(subs{i},'polygon')
    
    ind = ind & inpolygon(gB,subs{i})';
    
  end
end
end
