function ind = subsind(grains,subs)
% subindexing of EBSD data
%

ind = true(1,numel(grains));

for i = 1:length(subs)

  if ischar(subs{i}) || iscellstr(subs{i})

    miner = ensurecell(subs{i});
    minerals = get(grains,'minerals');
    phases = false(1,numel(minerals));
    
    for k=1:numel(miner)
      phases = phases | ~cellfun('isempty',regexpi(minerals,miner{k}));
    end 
    ind = ind & phases(grains.phase(:).');

%   elseif isa(subs{i},'grain')

%     ind = ind & ismember(ebsd.options.grain_id,get(subs{i},'id'))';

  elseif isa(subs{i},'logical')

    sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
    
    ind = ind & reshape(sub,size(ind));

  elseif isnumeric(subs{i})
    
    if any(subs{i} <= 0 | subs{i} > numel(grains))
      error('Out of range; index must be a positive integer or logical.')
    end
    
    iind = false(size(ind));
    iind(subs{i}) = true;
    ind = ind & iind;
    
  elseif isa(subs{i},'polygon')
    
    ind = ind & inpolygon(grains,subs{i})';
    
  end
end
