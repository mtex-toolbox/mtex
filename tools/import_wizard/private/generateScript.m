function str = generateScript(type,fn, data, interface, options, handles)

% load template file
str = file2cell([mtex_path filesep 'templates' filesep 'load' type 'template.m']);

%% specify crystal and specimen symmetries
if isa(data,'EBSD')
  [cs{1:numel(data)}] = get(data,'CS');
else
  cs = {get(data,'CS')};
end
ss = get(data,'SS');

str = replaceToken(str,'{crystal symmetry}',export_CS_tostr(cs));
str = replaceToken(str,'{specimen symmetry}',['symmetry(''',strrep(char(ss),'"',''), ''')']);


% plotting convention
plotdir = cell2mat(get(handles.plot_dir,'value'))==1;
plotdir = get(handles.plot_dir(plotdir),'string');
str = replaceToken(str,'{plotting convention}',['plotx2' lower(plotdir)]);


%% specify the file names

% main file names
[fnames,pname] = generateFileNames(fn);
str = replaceToken(str,'{path to files}',['''' pname '''']);
str = replaceToken(str,'{file names}',fnames);

% background, defocussing, defocussing background
d = {'bg','def','defbg'};
for t=1:3
  
  if iscell(fn{1}) && ~isempty(fn{t+1})
      
    [fnames,pname] = generateFileNames(fn{t+1});
    str = replaceToken(str,['{path to ' d{t} ' files}'],['''' pname '''']);
    str = replaceToken(str,['{' d{t} ' file names}'],fnames);
      
  else
    % remove lines
    pos = strmatch(['fname_' d{t} ' '],str);
    str(pos-3:pos) = [];
  end
end
    


%% specify crystal directions

if isa(data,'PoleFigure')
  hstr = {'{ ...'};
  for k = 1:length(data)
    hstr = [ hstr miller2string(get(data(k),'h'))]; %#ok<AGROW>
  end
  hstr = [ hstr '}'];
  str = replaceToken(str,'{Miller}',hstr);
end


%% specifiy structural coefficients for superposed pole figures

if isa(data,'PoleFigure') && length(get(data,'c')) > length(data)
  cstr = [{'%% Specifiy Structural Coefficients for Superposed Pole Figures'},{' '}];
  c = [];
  for k = 1:length(data)
    c = strcat(c,n2s(get(data(k),'c')),',');
  end
  cstr = [ cstr, strcat('c = {',c(1:end-1),'};'), {''}];
  copt = {',''superposition'',c'};    
else
  copt = {''};
  cstr = {''};
end

str = replaceToken(str,'c = {structural coefficients};',cstr);

%% Specify kernel of ODF import


if isa(data,'ODF') 
  
  psi = get(data,'psi');
  kname = get(psi,'name');
  hw = get(psi,'halfwidth');
  str = replaceToken(str,'{kernel name}',['''' kname '''']);
  str = replaceToken(str,'{halfwidth}',[xnum2str(hw/degree) '*degree']);
  
  if get(handles.exact,'value')
    str = replaceToken(str,'{resolution}',[get(handles.approx,'string') '*degree']);
  else
    str = replaceToken(str,...
      '''resolution'',{resolution}','''exact''');
  end  
end

%% import the data 

str = replaceToken(str,',{structural coefficients}',copt);
str = replaceToken(str,'{interface}',['''' interface '''']);

optionstr = option2str(options,'quoted');
if get(handles.rotate,'value')
  optionstr = [optionstr, ', ''rotate'', ',get(handles.rotateAngle,'string') '*degree'];
end
if get(handles.flipud,'value'), optionstr = [optionstr, ', ''flipud''']; end
if get(handles.fliplr,'value'), optionstr = [optionstr, ', ''fliplr''']; end
str = replaceToken(str,',{options}',optionstr);

if isa(data,'PoleFigure')
  
  % background, defoccusing, defoccusing background
  corrections = [];
  for t=1:3
  
    if iscell(fn{1}) && ~isempty(fn{t+1})
      corrections = [corrections,',''',d{t},''', pf_' d{t}]; %#ok<AGROW>
    else
      % remove lines
      pos = strmatch(['pf_' d{t} ' '],str);
      str(pos-2:pos) = [];
    end
    
  end
  if ~isempty(corrections)
    str = replaceToken(str,',{corrections}',corrections);
  else
    % remove lines
    pos = strmatch('% correct data',str);
    str(pos:pos+2) = [];
  end
end




function str = replaceToken(str,token,repstr)

if ~iscell(repstr) || length(repstr) <= 1
  str = regexprep(str,token,repstr);
else
  pos = strfind(str,token);
  line = find(~cellfun('isempty',pos),1);
  if isempty(line), return;end
  pos = pos{line};
  str = [str(1:line-1) ...
    {[str{line}(1:pos-1) repstr{1}]} ...
    repstr{2:end-1} ...
    {[repstr{end} str{line}(pos+length(token):end)]} ...
    str(line+1:end)];
end
  
function s = miller2string(m)

if any(strcmp(Laue(get(m,'CS')),{'-3m','-3','6/m','6/mmm'}))
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


function [fnames,pname] = generateFileNames(fn)

if iscell(fn{1}), fn = fn{1};end
[pname, fname] =  minpath(fn);

if filesep == '\'
  pname = regexprep(pname,'\','\\\');
  for k = 1:length(fn)
    fname{k} = regexprep(fname{k},'\','\\\');
  end
end

fnames = {'{...'};
for k = 1:length(fn)
  fnames= [ fnames, {strcat('[pname ''', fname{k}, '''], ...')}]; %#ok<AGROW>
end
fnames = [ fnames, {'}'}];
