function ind = subsind(ebsd,subs)
% subindexing of EBSD data
%

if isempty(subs)
  ind = true(1,numel(ebsd));
else
  ind = false(1,numel(ebsd));
end


for i = 1:length(subs)

  if ischar(subs{i}) || iscellstr(subs{i})

    min = ensurecell(subs{i});

    minerals = get(ebsd,'minerals');
    phases = false(1,length(minerals));
    for j =1:length(min)
      phases = phases | strncmpi(minerals,min{j},length(min{j}));
    end
    ind = ind | phases(ebsd.phase);

  elseif isa(subs{i},'grain')

    ind = ind | ismember(ebsd.options.grain_id,get(subs{i},'id'))';

  elseif isa(subs{i},'logical')

    ind = subs{i};

  elseif isnumeric(subs{i})

    ind(subs{i}) = true;

  end
end
