function value = get(obj,phase,vname)
% get object variable

if nargin > 2
  n = phase;
else
  n = ':';
  vname = phase;
end
% 
if any(strcmp(fields(obj),vname))
  if ischar(obj.(vname))
    value = obj.(vname);
  else
    value = obj.(vname)(n);
  end
elseif  any (strcmp (fields (obj.options(:)),vname))
  value = obj.options.(vname)(n); 
else
  switch vname
    case 'CS'
      value = getCSym(obj.orientations(n));
    case 'SS'
      value = getSSym(obj.orientations(n));
    case 'data'
      value = obj.orientations(n);
    case 'x'
      xy = cell2mat(obj.xy(n));
      value = xy(:,1);
    case 'y'
      xy = cell2mat(obj.xy(n));
      value = xy(:,2);
    otherwise
      s = options(obj);
      s = strcat(s(:),{' '});
      s = [s{:}];
      error('matlab:EBSD:UnknownField', ...
        ['Unknown field in EBSD object: ' inputname(1) ...
           '\n  data CS SS xy x y phase comment  \n  '  s]);
  end
end

 if iscell(value)
   if isnumeric(value{1})
    value = cell2mat(value);
   end
 end