function str = export_CS_tostr( cs,axis,angle )

switch cs
    case {'-1','2/m'}
        str = strcat('CS = symmetry(''', cs,''',', axis, ',' , angle, ');');
    case {'m-3','m-3m'}
        str = strcat('CS = symmetry(''', cs,''');');
    otherwise
        str = strcat('CS = symmetry(''', cs,''',', axis, ');');   
end