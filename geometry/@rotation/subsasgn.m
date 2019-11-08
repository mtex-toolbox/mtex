function r = subsasgn(r,s,b)
% overloads subsasgn

if isnumeric(r)
  r = b;
  r.a = [];
  r.b = [];
  r.c = [];
  r.d = [];
  r.i = [];
end

if ~isstruct(s)

  if isempty(b)
    r.a(s) = [];
    r.b(s) = [];
    r.c(s) = [];
    r.d(s) = [];
    r.i(s) = [];
  else
    b = rotation(b);
    r.a(s) = b.a;
    r.b(s) = b.b;
    r.c(s) = b.c;
    r.d(s) = b.d;
    r.i(s) = b.i;
  end
  
else
  switch s(1).type
  
    case '()'
      
      if numel(s)>1, b =  builtin('subsasgn',subsref(r,s(1)),s(2:end),b); end
      
      if isnumeric(b)
        r.a = subsasgn(r.a,s(1),b);
        r.b = subsasgn(r.b,s(1),b);
        r.c = subsasgn(r.c,s(1),b);
        r.d = subsasgn(r.d,s(1),b);
        if isempty(b)
          r.i = subsasgn(r.i,s(1),[]);
        else
          r.i = subsasgn(r.i,s(1),false(size(b)));
        end
      else
        b = rotation(b);
        r.a = subsasgn(r.a,s(1),b.a);
        r.b = subsasgn(r.b,s(1),b.b);
        r.c = subsasgn(r.c,s(1),b.c);
        r.d = subsasgn(r.d,s(1),b.d);
        r.i = subsasgn(r.i,s(1),b.i);
      end
    otherwise      
      r =  builtin('subsasgn',r,s,b);
  end      
end

end
