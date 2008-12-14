function str = exportEBSD(fn, ebsd, interface, options, handles)

str = ['%% created with import_wizard';{''}];

%% specify crystal and specimen symmetries

str = [ str; '%% specify crystal and specimen symmetries';{''}];

so3 = get(ebsd,'data');

ss = getSSym( so3 );
cs =[];

for i=1:numel(ebsd), cs = [cs ; getCSym( so3(i))]; end

str = [str; export_CS_tostr( cs ); {''}];
str = [ str; strcat('SS = symmetry(',char(ss),');')]; 

%% specify the file names

str = [ str; {''};'%% specify file names'; {''};'fname = { ...'];

for k = 1:length(fn)
    str = [ str; strcat('''', fn{k}, ''', ...')]; %#ok<AGROW>
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

%% post process data

if get(handles.rotate,'value')
  str = [str; {''}; '%% rotate EBSD data'; {''};...
    'ebsd = rotate(ebsd, axis2quat(zvector, ',get(handles.rotateAngle,'string'),'*degree));'];
end