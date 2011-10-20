function grains = subsref(grains,s)
% indexing of grain data
%
%% Syntax:
%  grains('Fe')        % returns data of phase Fe
%  grains({'Fe','Mg'}) % returns data of phase Fe and Mg
%  grains(ebsd)        % returns data of the grains grain
%

if isa(s,'double') || isa(s,'logical')

  grains = grains(s);


%% select grains by mineral name
elseif ischar(s.subs{1}) || iscell(s.subs{1})

  if iscell(s.subs{1})
    min = s.subs{1};
  else
    min = s.subs;
  end

  % which minerals to select
  minerals = get(grains,'minerals');
 
  phases = false(1,length(minerals));
  for i =1:length(min)
    phases = phases | strncmpi(minerals,min{i},length(min{i}));
  end
  
  % make ordering right
  gphases = [grains.phase];
  uphases = unique(gphases);
    
  loosephases = false(1,max(uphases));
  loosephases(uphases) = phases;
  
  
  % select grains
  ind = loosephases(gphases);

  grains = subsref(grains,ind);

%% select grains by EBSD data
elseif isa(s.subs{1},'EBSD')

  ind = ismember([grains.id],get(s.subs{1},'grain_id'));
  grains = subsref(grains,ind);

else

  grains = grains(s.subs{:});

end
