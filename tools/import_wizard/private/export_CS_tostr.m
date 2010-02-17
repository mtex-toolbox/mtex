function str = export_CS_tostr(cs)


if numel(cs) > 1
  str = '{...';
else 
  str = '';
end

for i=1:numel(cs)
  [c,angl] = get_axisangel(cs{i});
  axis =  strcat(n2s(c));
  angle =  strcat(n2s([angl{:}]),'*degree');
  
  if ~isempty(strmatch(Laue(cs{i}),{'-3','-3m','-6','6/mmm'}))
    if vector3d(Miller(1,0,0,cs{i})) == -yvector
      options = ',''a||x''';
    else
      options = ',''a||y''';
    end
  else
    options ='';
  end

  mineral = get(cs{i},'mineral');
  if ~isempty(mineral)
    options = [options,',''mineral'',''',mineral,'''']; %#ok<AGROW>
  end
  
  cs_t = strrep(char(cs{i}),'"','');

  switch cs_t
    case {'-1','2/m'}
      t = strcat('symmetry(''', cs_t,''',', axis, ',' , angle, options,')');
    case {'m-3','m-3m'}
      t = strcat('symmetry(''', cs_t,'''',options,')');
    otherwise
      t = strcat('symmetry(''', cs_t,''',', axis,options,')');
  end  
  
  if numel(cs) > 1
    str = [str; {t} ]; %#ok<AGROW>
    if i == numel(cs)
      str{end} = [ str{end} '}'];
    else
      str{end} = [ str{end} ',...'];
    end
  else
    str = [str t]; %#ok<AGROW>
  end
end


%%
function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end
