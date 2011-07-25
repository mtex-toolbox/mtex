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
      
  minerals = get(grains,'minerals');

  phases = find(cellfun(@(m) any(strcmpi(min,m)),minerals));
          
  ind = ismember([grains.phase],phases);
  
  grains = subsref(grains,ind);

%% select grains by EBSD data
elseif isa(s.subs{1},'EBSD')
        
  ind = ismember([grains.id],get(s.subs{1},'grain_id'));
  grains = subsref(grains,ind);
  
else
    
  grains = grains(s.subs{:});
    
end
