function str = exportPF( pn, fn, pf, interface, options )

str = ['%% created with import_wizard';{''}];

%% specify crystal and specimen symmetries

str = [ str; '%% specify crystal and specimen symmetries';{''}];

cs =get(pf,'CS');
ss = get(pf,'SS');

[c,angl] = get_axisangel( cs );
axis =  strcat(n2s(c));
angle =  strcat(n2s([angl{:}]));

cs = strrep(char(cs),'"','');
str = [str; export_CS_tostr( cs,axis,angle )];

str = [ str; strcat('SS = symmetry(''',strrep(char(ss),'"',''), ''');')];

%% specify the file names


% ordinary case
if ~iscell(fn{1}) 

  pn = strrep(pn,'\','/');
  pn = strrep(pn,'./','');

  str = [ str; {''};'%% specify file names'; {''};'% path to data files'; ...
    strcat('pname = ''',pn,''';')];

  str = [ str; {''};'% file names';'fname = { ...'];

  fn = path2filename(fn);
  for k = 1:length(fn)
    str = [ str; strcat('[pname,''', fn{k}, '''], ...')];
  end
  
  str = [ str; '};'; {''}];

   
else % xrdml pole figures
  
  str = [ str; {''};'%% specify file names'; {''};'fname = { ...'];
  str = [ str; '{...'];
  for i=1:length(fn{1})
    for k = 1:4
      str = [ str; strcat('''',fn{k}{i},''',...')];
    end
    if i<length(fn{1}),str = [ str; '},{...'];end
  end 
  str = [ str; '}};'; {''}];
end


%% specify crystal directions
str = [ str; '%% specify crystal directions'; {''};'h = { ...'];

if ~iscell(fn{1})
  for k = 1:length(pf)    
    str = [ str; cs2miller(pf(k))];
  end  
  str = [ str; '};'; {''}];
else
  str = [ str; '{...'];
  for i = 1:length(pf) 
    for k=1:4
      str = [ str; cs2miller(pf(i))];
    end
    if i<length(pf),str = [ str; '},{...'];end
  end  
  str = [ str; '}};'; {''}];
end

%% specifiy structural coefficients for superposed pole figures

if length(getc(pf)) > length(pf)
  str = [ str; {'%% specifiy structural coefficients for superposed pole figures';}];
  c = [];
  for k = 1:length(pf)
    c = strcat(c,n2s(get(pf(k),'c')),',');
  end
  str = [ str; strcat('c = {',c(1:end-1),'};'); {''}];
end

%% import the data 

str = [ str; '%% import the data'; {''}];

if ~iscell(fn{1})
  lpf = ['pf = loadPoleFigure(fname,h,CS,SS,''interface'',''',...
    interface,''''];
  if ~isempty(options), lpf = [lpf, ', ',option2str(options,'quoted')];end
  if length(getc(pf)) > length(pf), lpf = [lpf,',''superposition'',c'];end
  
  str = [str; [lpf ');']];
else
  str = [str;'pf=[];';{''};...
    'for k=1:length(fname)'; ...
      'pf = [pf, xrdml_merge(...'; ...
      'loadPoleFigure(fname{k},h{k},CS,SS,''interface'',''xrdml'')) ];';...
    'end'];
end

%% add plot 

str = [str; {''}; '%% plot imported polefigure'; {''};'plot(pf)'];


function s = cs2miller(pf)

m = get( pf,'h');
if any(strcmp(Laue(getCS(pf)),{'-3m','-3','6/m','6/mmm'}))
  s = strcat('Miller(',n2s(get(m,'h')),',',n2s(get(m,'k')), ...
    ',',n2s(-get(m,'h')-get(m,'k')),',',n2s(get(m,'l')),',CS), ...');
else
  s = strcat('Miller(',n2s(get(m,'h')),',',n2s(get(m,'k')), ...
    ',',n2s(get(m,'l')),',CS), ...');
end


function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*',',');
if length(n) > 1, s = ['[',s,']'];end
