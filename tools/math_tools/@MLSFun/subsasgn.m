function F = subsasgn(F,s,b)
% overloads subsasgn

if ~isa(F,'MLSFun') && ~isempty(b)
  F = b;
  F.values = [];
end

switch s(1).type
  case '()'
    if numel(s) > 1, b = builtin('subsasgn',subsref(F,s(1)),s(2:end),b); end
    s(1).subs = [':' s(1).subs];

    % remove functions
    if isempty(b)
      F.values = subsasgn(F.values,s(1),b);
      return
    end

    ensureCompatibleSymmetries(F,b);
    F.values = subsasgn(F.values,s(1),b.values);

  otherwise
    F = builtin('subsasgn',F,s,b);
end

end
