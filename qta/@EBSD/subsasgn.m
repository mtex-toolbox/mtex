function ebsd = subsasgn(ebsd,s,b)
% overloads subsasgn

if isa(b,'ebsd')
  
  switch s.type
    case '()'
      
      ebsd.options = structfun(@(x) subsasgn(x,s,b.options),ebsd.options,'UniformOutput',false);
      ebsd.rotations = subsasgn(ebsd.rotations,s,b.phases);
      ebsd.phases = subsasgn(ebsd.phases,s,b.phases);
            
    otherwise
      error('Wrong indexing. Only ()-indexing is allowed for EBSD!');
  end
  
elseif isempty(b)
  ebsd.options = structfun(@(x) subsasgn(x,s,[]),ebsd.options,'UniformOutput',false);
  ebsd.rotations = subsasgn(ebsd.rotations,s,[]);
  ebsd.phases = subsasgn(ebsd.phases,s,[]);
else
  
  error('Value must be of type EBSD!');
  
end
