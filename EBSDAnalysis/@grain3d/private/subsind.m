function ind = subsind(grains,subs)
  if numel(subs)==2 && ischar(subs{1}) && strcmpi(subs{1},'id')
    ind = reshape(grains.id2ind(subs{2}),size(subs{2}));
    if any(ind(:)==0)
      error('No data with the specified ids in the data set');
    end
    return
  end

  ind = true(length(grains),1);
      
  for i = 1:length(subs)
    
    if isa(subs{i},'logical')
    
      sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
      ind = ind & reshape(sub,size(ind));
    
    elseif isnumeric(subs{i})
      
      if any(subs{i} <= 0 | subs{i} > length(grains))
        error('Out of range; index must be a positive integer or logical.')
      end
      
      ind = subs{i};
      return
    else
      error 'not supported (yet)'
    end
  end
end