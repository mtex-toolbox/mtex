function ind = subsind(grains3,subs)
  
  if numel(subs)==2 && ischar(subs{1}) && strcmpi(subs{1},'id')
    ind = reshape(grains3.id2ind(subs{2}),size(subs{2}));
    if any(ind(:)==0)
      error('No data with the specified ids in the data set');
    end
    return
  end

  ind = true(length(grains3),1);
      
  for i = 1:length(subs)
 
    if ischar(subs{i}) && strcmpi(subs{i},'indexed')  % only indexed grains
  
      ind = ind & grains3.isIndexed;

    elseif ischar(subs{i}) || iscellstr(subs{i})  % grains by phase
    
      phases = false(length(grains3.phaseMap),1);
      mineralsSubs = ensurecell(subs{i});
      phaseNumbers = cellfun(@num2str,num2cell(grains3.phaseMap(:)),'Uniformoutput',false);
      
      for k=1:numel(mineralsSubs)
        phases = phases ...
          | strcmpi(grains3.mineralList(:),mineralsSubs{k}) ...
          | strcmpi(phaseNumbers,mineralsSubs{k});
      end
  
      % if no complete match was found allow also for partial match
      if ~any(phases)
        for k=1:numel(mineralsSubs)
          phases = phases ...
            | strncmpi(grains3.mineralList(:),mineralsSubs{k},length(mineralsSubs{k}));
        end
      end
      
      if ~any(phases)
        disp(' ');
        warning off backtrace
        warning(['There is no such phase "' mineralsSubs{1} '". Maybe you mispelled it?']);
        warning on backtrace
      end
      
      ind = ind & phases(grains3.phaseId(:));

    elseif isa(subs{i},'logical') 
    
      sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
      ind = ind & reshape(sub,size(ind));
    
    elseif isnumeric(subs{i})
      
      if any(subs{i} <= 0 | subs{i} > length(grains3))
        error('Out of range; index must be a positive integer or logical.')
      end
      
      ind = subs{i};
      return
    else
      error 'not supported (yet)'
    end
  end
end