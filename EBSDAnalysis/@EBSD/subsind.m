function ind = subsind(ebsd,subs)
% subindexing of EBSD data
%
% See also
% EBSD/subsref EBSD/findByLocation

if numel(subs)==2 && all(cellfun(@isnumeric, subs))

  % ebsd(x,y) is the pixel in row x and column y on a gridded map, so the
  % coordinate lookup has to be asked for by name
  error('MTEX:EBSD:ambiguousIndex',['%s\n\n  %s\n\n%s\n\n  %s\n\n%s'],...
    'ebsd(x,y) is ambiguous and therefore no longer supported. To select the measurement closest to the coordinate (x,y) write',...
    'ebsd(''xy'',x,y)',...
    'which means the same on a gridded map and on a list. Note that on a gridded map',...
    'ebsd(i,j)',...
    'is the pixel in row i and column j instead, which is a different thing.');

elseif numel(subs)==2 && (ischar(subs{1}) || isstring(subs{1})) && strcmpi(subs{1},'id')
  ind = ebsd.id2ind(subs{2});
  if any(ind(:)==0)
    error('No data with the specified ids in the data set');
  end
  return
elseif numel(subs)==3 && (ischar(subs{1}) || isstring(subs{1})) && strcmpi(subs{1},'xy')
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
  elseif ischar(subs{i}) || iscellstr(subs{i}) || isstring(subs{i})
    
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
      warning("There is no such phase " + mineralsSubs{1} + ". Maybe you mispelled it?");
      warning on backtrace
    end
    
    phaseId = reshape(ebsd.phaseId,size(ebsd));
    phaseId(isnan(phaseId)) = 1+numel(phases);
    phases(end+1) = false; %#ok<AGROW>
    
    ind = ind & phases(phaseId);
    
  elseif isa(subs{i},'symmetry')
    
    phaseId = ebsd.cs2phaseId(subs{i});
    ind = ind(:) & ebsd.phaseId == phaseId;
    
  elseif isa(subs{i},'grain2d')

    assert(ebsd.hasGrainId,...
      "There is no grainId stored within your EBSD data." + newline +...
      "You should compute grains by the command" + newline + newline + ...
      "  [grains,ebsd] = calcGrains(ebsd)" + newline + newline +...
      "before you can select EBSD data by grains." + newline);
    
    ind = ind(:) & ismember(ebsd.prop.grainId(:),subs{i}.id);
    
  elseif isa(subs{i},'logical')
    
    %sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind(:) & subs{i}(:);
    
  elseif isnumeric(subs{i})
    
    ind = subs{i};
    return
    
  end
end
