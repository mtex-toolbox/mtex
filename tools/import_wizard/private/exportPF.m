function str = exportPF(fn, pf, interface, options, handles )

str = ['%% created with import_wizard';{''}];

%% specify crystal and specimen symmetries

str = [ str; '%% specify crystal and specimen symmetries';{''}];

cs = get(pf,'CS');
ss = get(pf,'SS');

str = [str; export_CS_tostr(cs)];

str = [ str; strcat('SS = symmetry(''',strrep(char(ss),'"',''), ''');')];

% plotting convention
plotdir = cell2mat(get(handles.plot_dir,'value'))==1;
plotdir = get(handles.plot_dir(plotdir),'string');
str = [ str; {''};['plotx2' lower(plotdir) '    % plotting convention']];


%% specify the file names

str = [ str; {''};'%% specify file names'; {''}];

% ordinary case 
if ~iscell(fn{1})

  [pname, fname] =  minpath(fn);
  str = [ str; {''};strcat('pname = ''', pname,''';'); {''};'fname = {...']; 
  for k = 1:length(fn)
      str = [ str; strcat('[ pname ''', fname{k}, '''], ...')];
  end
  str = [ str; '};'; {''}];
else
  if strcmp(interface,'xrdml')
    d = {'','_bg','_def','_defbg'};
    for t=1:4
      [pname, fname] =  minpath(fn{t});
      str = [ str; {''};strcat('pname = ''', pname,''';'); {''};...
        strcat('fname',d{t},' = {...')]; 
        for k = 1:length(fn{t})
          str = [ str; strcat('[ pname ''', fname{k}, '''], ...')];
        end
      str = [ str; '};'; {''}];
    end
  end
end


%% specify crystal directions
str = [ str; '%% specify crystal directions'; {''};'h = { ...'];

for k = 1:length(pf)    
  str = [ str; cs2miller(pf(k))]; %#ok<AGROW>
end  
str = [ str; '};'; {''}];

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
  if strcmp(interface,'xrdml')
    for k=1:4
      str = [str; strcat('pf',d{k},' = loadPoleFigure(fname',d{k},',h,CS,SS,''interface'',''xrdml'');')]; 
    end
      str = [str; {''}; ...
        'pf_corrected = correct(pf,...';
        strcat('''BACKGROUND'',pf',d{2},',...');...
        strcat('''DEFOCUSING'',pf',d{3},',...');...
        strcat('''DEFOCUSING BACKGROUND'',pf',d{4},');')];
  end
end


%% post process pole figure

if get(handles.rotate,'value')
  str = [str; {''}; '%% rotate pole figure'; {''};...
    'pf = rotate(pf,',get(handles.rotateAngle,'string'),'*degree)'];
end

if get(handles.fliplr,'value')
  str = [str; {''}; '%% flip pole figures left to right'; {''};...
    'pf = fliplr(pf);'];  
end

if get(handles.flipud,'value')
  str = [str; {''}; '%% flip pole figures upside down'; {''};...
    'pf = flipud(pf);'];  
end

%if get(handles.dnv,'value')
%  str = [str; {''}; '%% delete negative values'; {''};...
%    'pf = delete(pf,getdata(pf)<0);'];  
%end

%if get(handles.setnv,'value')
%  str = [str; {''}; '%% set negative values'; {''};...
%    'pf = setdata(pf,',get(handles.rnv,'string'),',getdata(pf)<0)'];
%end


%% add plot 

str = [str; {''}; '%% plot imported polefigure'; {''}];
  
if ~iscell(fn{1})
  str = [str; 'plot(pf)'];
else
  if strcmp(interface,'xrdml')
    str = [str; 'plot(pf_corrected)'];
  end
end

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
