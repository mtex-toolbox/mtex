function dispStruct(s,varargin)
% recursively display a structure

for fn = fieldnames(s).'
  
  value = s.(char(fn));
  switch class(value)
    case 'double'
      if numel(value) < 20
        out = xnum2str(value);
      else
        out = [size2str(value) ' double'];
      end
    case 'logical'
      if value
        out = 'true';
      else
        out = 'false';
      end
    case 'struct'
      
      id = pushTemp(value);
      out = ['<a href="matlab:dispStruct(pullTemp(' int2str(id) '))">show struct</a>'];
      
    otherwise
      try
        out = char(value,varargin{:});
      catch
        out = [];
      end
  end
 
  disp([' ' char(fn) ': ' out]);
end
         


end