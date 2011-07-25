function ebsd = subsref(ebsd,s)
% indexing of EBSD data
%
%% Syntax:
%  ebsd('Fe')        % returns data of phase Fe
%  ebsd({'Fe','Mg'}) % returns data of phase Fe and Mg
%  ebsd(grain)       % returns data of the grains grain
%

if isa(s,'double') || isa(s,'logical')
  
  ebsd.options = structfun(@(x) x(s),ebsd.options,'UniformOutput',false);
  ebsd.rotations = ebsd.rotations(s);
  ebsd.phases = ebsd.phases(s);
        
elseif ischar(s.subs{1}) || iscell(s.subs{1})
  
  if iscell(s.subs{1})
    min = s.subs{1};
  else
    min = s.subs;
  end
      
  minerals = get(ebsd,'minerals');

  phases = find(cellfun(@(m) any(strcmpi(min,m)),minerals));
          
  ind = ismember(ebsd.phases,phases);
  
  ebsd = subsref(ebsd,ind);

  
elseif isa(s.subs{1},'grain')
        
  ind = ismember(ebsd.options.grain_id,get(s.subs{1},'id'));
  ebsd = subsref(ebsd,ind);
  
else
    
  ebsd.options = structfun(@(x) subsref(x,s),ebsd.options,'UniformOutput',false);
  ebsd.rotations = subsref(ebsd.rotations,s);
  ebsd.phases = subsref(ebsd.phases,s);
    
end


  
