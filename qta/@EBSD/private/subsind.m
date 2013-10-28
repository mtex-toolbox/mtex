function ind = subsind(ebsd,subs)
% subindexing of EBSD data
%

ind = true(1,length(ebsd));

for i = 1:length(subs)

  % ebsd('mineralname') or ebsd({'mineralname1','mineralname2'})
  if ischar(subs{i}) || iscellstr(subs{i})
    
    mineralsSubs = ensurecell(subs{i});
    phaseNumbers = cellfun(@num2str,num2cell(ebsd.phaseMap(:)'),'Uniformoutput',false);
    
    phases = false(1,numel(ebsd.minerals));
    
    for k=1:numel(mineralsSubs)
      phases = phases ...
        | ~cellfun('isempty',regexpi(ebsd.minerals,mineralsSubs{k})) ...
        | strcmpi(phaseNumbers,mineralsSubs{k});
    end
    
    ind = ind & phases(ebsd.phaseId(:).');
    
  elseif isa(subs{i},'symmetry')
    
    phases = false(1,length(ebsd.CS));
    for k=1:length(ebsd.CS)
      if isa(ebsd.CS{k},'symmetry') && ebsd.CS{k} == subs{i} && ...
          (isempty(get(subs{i},'mineral')) || strcmp(get(ebsd.CS{k},'mineral'),get(subs{i},'mineral')))
        phases(k) = true;
      end
    end
    ind = ind & phases(ebsd.phaseId(:).');
    
  elseif isa(subs{i},'grain')
    
    ind = ind & ismember(ebsd.options.grain_id,get(subs{i},'id'))';
    
  elseif isa(subs{i},'logical')
    
    sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind & reshape(sub,size(ind));
    
  elseif isnumeric(subs{i})
    
    iind = false(size(ind));
    iind(subs{i}) = true;
    ind = ind & iind;
    
    %   elseif isa(subs{i},'polygon')
    
    %     ind = ind & inpolygon(ebsd,subs{i})';
    
  end
end
