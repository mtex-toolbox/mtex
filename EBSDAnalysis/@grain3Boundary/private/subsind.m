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

if isempty(subs), return; end

% other indexing
if (length(subs)==2 && (subs{2} == "ind"))
  ind = subs{1};
  assert((isnumeric(ind) || islogical(ind))...
  , 'indexing only supported for numerical or logical values')
elseif islogical(subs{1})
  ind = ind & subs{1};
elseif length(subs)==2 && subs{2} == "id"
  ind = id2ind(gB,subs{1});
elseif isnumeric(subs{1})
  ind = subs{1};  
elseif isempty(subs)
else
  error 'error'
end
end
