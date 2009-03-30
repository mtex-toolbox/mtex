function str = export_CS_tostr(cs)

[c,angl] = get_axisangel(cs);
axis =  strcat(n2s(c));
angle =  strcat(n2s([angl{:}]));

if vector3d(Miller(1,0,0,cs)) == -yvector
  options = ',''a||y''';    
else
  options = '';
end

cs = strrep(char(cs),'"','');

switch cs
  case {'-1','2/m'}
    str = strcat('CS = symmetry(''', cs,''',', axis, ',' , angle, options,');');
  case {'m-3','m-3m'}
    str = strcat('CS = symmetry(''', cs,'''',options,');');
  otherwise
    str = strcat('CS = symmetry(''', cs,''',', axis,options,');');
end

%%
function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end
