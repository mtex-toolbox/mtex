function ind = subsind(gB,subs)

ind = true(length(gB),1);

for i = 1:length(subs)
  
  if ischar(subs{i}) || iscellstr(subs{i})
    
    miner = ensurecell(subs{i});
    
    ind = ind & gB.hasPhase(miner{:});
                      
    %   elseif isa(subs{i},'grain')
    
    %     ind = ind & ismember(ebsd.options.grain_id,get(subs{i},'id'))';

    
  elseif isa(subs{i},'logical')
    
    sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind & reshape(sub,size(ind));
    
  elseif isnumeric(subs{i})
    
    if any(subs{i} <= 0 | subs{i} > length(gB))
      error('Out of range; index must be a positive integer or logical.')
    end
    
    iind = false(size(ind));
    iind(subs{i}) = true;
    ind = ind & iind;
    
  elseif isa(subs{i},'polygon')
    
    ind = ind & inpolygon(gB,subs{i})';
    
  end
end
end
