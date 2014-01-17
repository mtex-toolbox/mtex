function varargout = subsref(v,s)
%overloads subsref


if isa(s,'double') || isa(s,'logical')

  v.x = v.x(s);
  v.y = v.y(s);
  v.z = v.z(s);
  varargout{1} = v;
  
else
  
  switch s(1).type
    case '()'
  
      v.x = subsref(v.x,s(1));
      v.y = subsref(v.y,s(1));
      v.z = subsref(v.z,s(1));
      
      if numel(s)>1
        [varargout{1:nargout}] = builtin('subsref',v,s(2:end));
      else
        varargout{1} = v;
      end
      
    case '.'
      try
        [varargout{1:nargout}] = builtin('subsref',v,s);
      catch
        [varargout{1:nargout}] = subsref@dynOption(v,s);
      end
      
      
  end
end

end
