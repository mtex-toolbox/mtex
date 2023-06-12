function ind = subsind(grains,subs)
  if numel(subs)==2 && ischar(subs{1}) && strcmpi(subs{1},'id')
    ind = reshape(grains.id2ind(subs{2}),size(subs{2}));
    if any(ind(:)==0)
      error('No data with the specified ids in the data set');
    end
    return
  elseif
    
  else
    error 'not supported (yet)'
  end
end