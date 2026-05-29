function dispStruct(s,varargin)
% recursively display a structure

for fn = fieldnames(s).'
  
  value = s.(char(fn));
  switch class(value)
    case {'double','single','int32','uint8','uint16','uint32'}
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

      if ~getMTEXpref('generatingHelpMode')
        id = pushTemp(value);
        out = ['<a href="matlab:dispStruct(pullTemp(' int2str(id) '))">show struct</a>'];
      else
        continue
      end
    case 'string'
      out = char(join(value));

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