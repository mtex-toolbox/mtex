function str = exportEBSD( pn, fn, ebsd, interface, options )

str = ['%% created with import_wizard';{''}];

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

str = [ str; {''};'%% specify file names'; {''};'fname = { ...'];

for k = 1:length(fn)
    str = [ str; strcat('''', fn{k}, ''', ...')];
end
str = [ str; '};'; {''}];

%% import the data 

str = [ str; '%% import the data'; {''}];
lpf = ['ebsd = loadEBSD(fname,CS,SS,''interface'',''',...
  interface,''''];

if ~isempty(options)
  lpf = [lpf, ', ',option2str(options,'quoted')];
end

str = [str; [lpf ');']];



function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end
