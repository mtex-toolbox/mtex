function ind = subsind(grains,subs)

% dermine grains by x,y coordinates
if numel(subs)==2 && all(cellfun(@isnumeric, subs))
  ind = grains.findByLocation([subs{:}]);
  return
elseif numel(subs)==2 && ischar(subs{1}) && strcmpi(subs{1},'id')
  ind = grains.id2ind(subs{2});
  if any(ind(:)==0)
    error('No data with the specified ids in the data set');
  end
  return
end

ind = true(length(grains),1);
      
for i = 1:length(subs)
  
  if ischar(subs{i}) && strcmpi(subs{i},'indexed')
  
    ind = ind & grains.isIndexed;
  
  elseif ischar(subs{i}) || iscellstr(subs{i})
    
    
    phases = false(length(grains.phaseMap),1);
    mineralsSubs = ensurecell(subs{i});
    phaseNumbers = cellfun(@num2str,num2cell(grains.phaseMap(:)),'Uniformoutput',false);
    
    for k=1:numel(mineralsSubs)
      phases = phases ...
        | strcmpi(grains.mineralList(:),mineralsSubs{k}) ...
        | strcmpi(phaseNumbers,mineralsSubs{k});
    end

    % if no complete match was found allow also for partial match
    if ~any(phases)
      for k=1:numel(mineralsSubs)
        phases = phases ...
          | strncmpi(grains.mineralList(:),mineralsSubs{k},length(mineralsSubs{k}));
      end
    end
    
    if ~any(phases)
      disp(' ');
      warning off backtrace
      warning(['There is no such phase "' mineralsSubs{1} '". Maybe you mispelled it?']);
      warning on backtrace
    end
    
    %miner = ensurecell(subs{i});
    %alt_mineral = cellfun(@num2str,num2cell(grains.phaseMap),'Uniformoutput',false);    
    %for k=1:numel(miner)
    %  phases = phases | ~cellfun('isempty',regexpi(grains.mineralList(:),['^' miner{k}])) | ...
    %    strcmpi(alt_mineral(:),miner{k});
    %end
    ind = ind & phases(grains.phaseId(:));
    
  elseif isa(subs{i},'logical')
    
    sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind & reshape(sub,size(ind));
    
  elseif isnumeric(subs{i})
    
    if any(subs{i} <= 0 | subs{i} > length(grains))
      error('Out of range; index must be a positive integer or logical.')
    end
    
    ind = subs{i};
    return
        
  elseif isa(subs{i},'polygon')
    
    ind = ind & inpolygon(grains,subs{i})';
    
  end
end
end
