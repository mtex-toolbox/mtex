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
if (length(subs)==2 && (subs{2} == "ind"))
  ind = subs{1};
  assert((isnumeric(ind) || islogical(ind))...
  , 'indexing only supported for numerical or logical values')
elseif (isscalar(subs) || (length(subs)==2 && (subs{2} == "id")))
  if isnumeric(subs{1})
    id = subs{1};
  elseif islogical(subs{1})
    id = find(subs{1});
  else
    error 'indexing only supported for numerical or logical values'
  end
  ind = id2ind(gB,id);
elseif isempty(subs)
else
  error 'error'
end
end
