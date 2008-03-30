function str = exportEBSD( pn, fn, ebsd, options )

str = ['%% created by importwizard';{''}];

%% specify crystal and specimen symmetries

str = [ str; '%% specify crystal and specimen symmetries';{''}];
[cs, ss] = getSym(ebsd);

[c,angl] = get_axisangel( cs );
axis =  strcat(n2s(c));
angle =  strcat(n2s([angl{:}]));

cs = strrep(char(cs),'"','');
str = [str; export_CS_tostr( cs,axis,angle )];

str = [ str; strcat('SS = symmetry(''',strrep(char(ss),'"',''), ''');')];

%% specify the file names

pn = strrep(pn,'\','/');
pn = strrep(pn,'./','');

str = [ str; {''};'%% specify file names'; {''};'% path to data files'; ...
  strcat('pname = ''',pn,''';')];

str = [ str; {''};'% file names';'fname = { ...'];

for k = 1:length(fn)
    str = [ str; strcat('[pname,''', fn{k}, '''], ...')];
end
str = [ str; '};'; {''}];


%% specifiy options


if ~isempty(options)
ostr = {'options = { ...'};
for k=1:length(options)
  if ~isa(options{k}, 'char')
    ostr = [ ostr; strcat( '[', num2str(options{k}),'],...')] ;
  else ostr =  [ostr; strcat( '''', options{k},''',...' )];
  end
end
ostr = [ostr; '};'];


str = [ str; '%% import options for EBSD data';{''}; ...
        ostr; {''};];
    
istr = '''interface'',''generic'',';
end

%% import the data 

str = [ str; '%% import the data'; {''}];
lpf = ['pf = loadEBSD(fname,CS,SS,', istr, 'options'];

%if length(getc(pf)) > length(pf), lpf = [lpf,',''superposition'',c'];end

str = [str; [lpf ');']];

function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end
