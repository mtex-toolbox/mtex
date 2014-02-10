function ebsd = subsasgn(ebsd,s,b)
% overloads subsasgn

if ~isa(ebsd,'EBSD')
  ebsd = EBSD;
  ebsd.allCS = b.allCS;
end

if isa(s,'double') || isa(s,'logical')

  ss.type = '()'; ss.subs{1} = s;

  if isempty(b) % remove measurements
    
    ebsd.options = structfun(@(x) subsasgn(x,ss,[]),ebsd.options,'UniformOutput',false);
    ebsd.rotations = subsasgn(ebsd.rotations,ss,[]);
    ebsd.phaseId = subsasgn(ebsd.phaseId,ss,[]);
    
  elseif isa(b,'char') % assign a new phase
    
    ind = strcmp(b,ebsd.minerals);
    if any(ind)
      newphase = find(ind,1);
    else
      newphase = numel(ebsd.phaseMap)+1;
      ebsd.phaseMap(newphase) = 0;
      ebsd.allCS{newphase} = b;      
    end
    
    ebsd.phaseId = subsasgn(ebsd.phaseId,ss,newphase);
    
  elseif isa(b,'EBSD') % copy measurements
    
    fn = fieldnames(ebsd.options);
    for ifn = 1:numel(fn)
      ebsd.options.(fn{ifn}) = subsasgn(ebsd.options.(fn{ifn}),ss,b.options.(fn{ifn}));
    end
    ebsd.rotations = subsasgn(ebsd.rotations,ss,b.rotations);
    ebsd.phaseId = subsasgn(ebsd.phaseId,ss,b.phaseId);
    
  else
    
    error('Right hand side should be of type EBSD or character.')
    
  end

  return
  
end
  
switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  subsasgn(subsref(ebsd,s(1)),s(2:end),b); end
    
    if isempty(b)
      
      ebsd = subsasgn@dynProp(ebsd,s(1),[]);
      ebsd.rotations = subsasgn(ebsd.rotations,s(1),[]);
                  
    else
      
      ebsd = subsasgn@dynProp(ebsd,s(1),b);
      ebsd.rotations = subsasgn(ebsd.rotations,s(1),b.rotations);
                  
    end
    
  otherwise
    
    % maybe we can adress the ebsd object directly
    try %#ok<TRYNC>
      ebsd = builtin('subsasgn',ebsd,s,b);
      return
    end
    
    % maybe it is an option
    if ebsd.isOption(s(1).subs)
      ebsd = subsasgn@dynOption(ebsd,s,b);
    else % otherwise a property
      ebsd = subsasgn@dynProp(ebsd,s,b);
    end

end
end
