function ind = subsind(ebsd,subs)
% subindexing of EBSD data
%

if numel(subs)==2 && all(cellfun(@isnumeric, subs))
  ind = ebsd.findByLocation([subs{:}]);
  return
elseif numel(subs)==2 && ischar(subs{1}) && strcmpi(subs{1},'id')
  ind = ebsd.id2ind(subs{2});
  if any(ind(:)==0)
    error('No data with the specified ids in the data set');
  end
  return
elseif numel(subs)==3 && ischar(subs{1}) && strcmpi(subs{1},'xy')
  ind = ebsd.findByLocation(subs{2},subs{3});
  if any(ind(:)==0)
    error('No data with the specified coordinates in the data set');
  end
  return
else
  %ind = true(length(ebsd),1);
  ind = true(size(ebsd));
end
  
for i = 1:length(subs)

  if ischar(subs{i}) && strcmpi(subs{i},'indexed')
  
    ind = ind & ebsd.isIndexed;
  
  % ebsd('mineralname') or ebsd({'mineralname1','mineralname2'})
  elseif ischar(subs{i}) || iscellstr(subs{i})
    
    mineralsSubs = ensurecell(subs{i});
    phaseNumbers = cellfun(@num2str,num2cell(ebsd.phaseMap(:)),'Uniformoutput',false);
    
    phases = false(numel(ebsd.CSList),1);
    
    for k=1:numel(mineralsSubs)
      phases = phases ...
        | strcmpi(ebsd.mineralList(:),mineralsSubs{k}) ...
        | strcmpi(phaseNumbers,mineralsSubs{k});
    end

    % if no complete match was found allow also for partial match
    if ~any(phases)
      for k=1:numel(mineralsSubs)
        phases = phases ...
          | strncmpi(ebsd.mineralList(:),mineralsSubs{k},length(mineralsSubs{k}));
      end
    end
    
    if ~any(phases)
      disp(' ');
      warning off backtrace
      warning(['There is no such phase "' mineralsSubs{1} '". Maybe you mispelled it?']);
      warning on backtrace
    end
    
    phaseId = reshape(ebsd.phaseId,size(ebsd));
    phaseId(isnan(phaseId)) = 1+numel(phases);
    phases(end+1) = false;
    
    ind = ind & phases(phaseId);
    
  elseif isa(subs{i},'symmetry')
    
    phases = false(1,length(ebsd.CSList));
    for k=1:length(ebsd.CSList)
      if isa(ebsd.CSList{k},'symmetry') && ebsd.CSList{k} == subs{i} && ...
          (isempty(subs{i}.mineral) || strcmp(ebsd.CSList{k}.mineral,subs{i}.mineral))
        phases(k) = true;
      end
    end
    ind = ind(:) & ebsd.phaseId==find(phases);
    
  elseif isa(subs{i},'grain2d')
    
    if ~ebsd.isProp('grainId')
      error('%s\n\n%s\n',['There is no grainId stored within your EBSD data. ' ...
        'You should compute grains by the command'],...
        '  [grains,ebsd.grainId] = calcGrains(ebsd)');
    end
    ind = ind(:) & ismember(ebsd.prop.grainId(:),subs{i}.id);
    
  elseif isa(subs{i},'logical')
    
    %sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind(:) & subs{i}(:);
    
  elseif isnumeric(subs{i})
    
    ind = subs{i};
    return
    
  end
end
