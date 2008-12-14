function str = export_CS_tostr( cs )

if numel(cs) > 1
  str = ['CS = [...'];
else 
  str = 'CS = ';
end

for i=1:numel(cs)
  [c,angl] = get_axisangel( cs(i) );
  axis =  strcat(n2s(c));
  angle =  strcat(n2s([angl{:}]));

  cs_t = char(cs(i));

  switch cs_t
    case {'''-1''','''2/m'''}
      t = strcat('symmetry(', cs_t,',', axis, ',' , angle, ')');
    case {'''m-3''','''m-3m'''}
      t =  strcat('symmetry(', cs_t,')');
    otherwise
      t = strcat('symmetry(', cs_t,',', axis, ')'); 
  end
  if numel(cs) > 1
    str = [str; {t} ];
    if i == numel(cs)
      str{end} = [ str{end} '];'];
    else
      str{end} = [ str{end} ',...'];
    end
  else str = [str t ';'];
  end
  
end