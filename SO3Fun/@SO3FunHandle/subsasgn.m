function SO3F = subsasgn(SO3F, s, b)
% overloads subsasgn

if ~isa(SO3F,'SO3FunHandle') && ~isempty(b)
  SO3F = b;
  SO3F.fun = @(r) 0;
end

switch s(1).type
  case '()'
      
    if numel(s) > 1, b =  builtin('subsasgn', subsref(SO3F,s(1)), s(2:end), b); end
    
    s(1).subs = [':' s(1).subs];
    
    % remove functions
    if isempty(b)
      SO3F.fun = @(rot) subsasgn(reshape(SO3F.eval(rot),[numel(rot) size(SO3F)]) ,s(1), b);
      return
    end
    
    ensureCompatibleSymmetries(SO3F,b);

    SO3F.fun = @(rot) subsasgn(reshape(SO3F.eval(rot),[numel(rot) size(SO3F)]) ,s(1), reshape(b.eval(rot),[numel(rot) size(b)]));
        
  otherwise
    
    SO3F =  builtin('subsasgn',SO3F,s,b);    
end

end
