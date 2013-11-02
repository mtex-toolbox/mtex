function ebsd = subsasgn(ebsd,s,b)
% overloads subsasgn

if ~isa(ebsd,'EBSD')
  ebsd = EBSD;
  ebsd.CS = b.CS;
  ebsd.SS = b.SS;
end

if isa(s,'double') || isa(s,'logical')

  ss.type = '()'; ss.subs{1} = s;

  if isempty(b) % remove measurements
    
    ebsd.options = structfun(@(x) subsasgn(x,ss,[]),ebsd.options,'UniformOutput',false);
    ebsd.rotations = subsasgn(ebsd.rotations,ss,[]);
    ebsd.phase = subsasgn(ebsd.phase,ss,[]);
    
  elseif isa(b,'char') % assign a new phase
    
    minerals = get(ebsd,'minerals');
    ind = strcmp(b,minerals);
    if any(ind)
      newphase = find(ind,1);
    else
      newphase = numel(ebsd.phaseMap)+1;
      ebsd.phaseMap(newphase) = 0;
      ebsd.CS{newphase} = b;      
    end
    
    ebsd.phase = subsasgn(ebsd.phase,ss,newphase);
    
  elseif isa(b,'EBSD') % copy measurements
    
    fn = fieldnames(ebsd.options);
    for ifn = 1:numel(fn)
      ebsd.options.(fn{ifn}) = subsasgn(ebsd.options.(fn{ifn}),ss,b.options.(fn{ifn}));
    end
    ebsd.rotations = subsasgn(ebsd.rotations,ss,b.rotations);
    ebsd.phase = subsasgn(ebsd.phase,ss,b.phase);
    
  else
    
    error('Right hand side should be of type EBSD or character.')
    
  end

elseif strcmp(s.type,'()')

  ind = subsind(ebsd,s.subs);
  ebsd = subsasgn(ebsd,ind,b);

end
