function ebsd = subsasgn(ebsd,s,b)
% overloads subsasgn

if ~isa(ebsd,'EBSD')
  ebsd = EBSD;
  ebsd.CS = b.CS;
  ebsd.SS = b.SS;
end

if isa(s,'double') || isa(s,'logical')
  
  ss.type = '()'; ss.subs{1} = s;
  
  if isempty(b)
    ebsd.options = structfun(@(x) subsasgn(x,ss,[]),ebsd.options,'UniformOutput',false);
    ebsd.rotations = subsasgn(ebsd.rotations,ss,[]);
    ebsd.phases = subsasgn(ebsd.phases,ss,[]);
  elseif isa(b,'EBSD')
    ebsd.options = structfun(@(x) subsasgn(x,ss,b.options),ebsd.options,'UniformOutput',false);
    ebsd.rotations = subsasgn(ebsd.rotations,ss,b.rotations);
    ebsd.phases = subsasgn(ebsd.phases,ss,b.phases);
  else
    error('Right hand side should be of type EBSD.')
  end
        
elseif strcmp(s.type,'()')

  ind = subsind(ebsd,s.subs);
  ebsd = subsasgn(ebsd,ind,b);

end
