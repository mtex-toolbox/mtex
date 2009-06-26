function str = exportEBSD(fn, ebsd, interface, options, handles)

% load template file
str = file2cell([mtex_path filesep 'templates' filesep 'loadEBSDtemplate.m']);

%% specify crystal and specimen symmetries

[cs, ss] = getSym(ebsd,'all');

str = replaceToken(str,'<crystal symmetry>',export_CS_tostr(cs));
str = replaceToken(str,'<specimen symmetry>',['symmetry(''',strrep(char(ss),'"',''), ''')']);


% plotting convention
plotdir = cell2mat(get(handles.plot_dir,'value'))==1;
plotdir = get(handles.plot_dir(plotdir),'string');
str = replaceToken(str,'<plotting convention>',['plotx2' lower(plotdir)]);


%% specify the file names

fnames = {'{...'};
for k = 1:length(fn)
    fnames= [ fnames, {strcat('''', fn{k}, ''', ...')}]; %#ok<AGROW>
end
fnames = [ fnames, {'};'}];
str = replaceToken(str,'<file names>',fnames);


%% specify crystal directions

hstr = {'{ ...'};
for k = 1:length(pf)    
  hstr = [ hstr cs2miller(pf(k))]; %#ok<AGROW>
end  
hstr = [ hstr '};'];
str = replaceToken(str,'<Miller>',hstr);


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

str = replaceToken(str,'<interface>',['''' interface '''']);

str = replaceToken(str,'<options>',option2str(options,'quoted'));

%% post process data

%if get(handles.rotate,'value')
%  str = [str; {''}; '%% rotate EBSD data'; {''};...
%    'ebsd = rotate(ebsd, axis2quat(zvector, ',get(handles.rotateAngle,'string'),'*degree));'];
%end

function str = replaceToken(str,token,repstr)

if ~iscell(repstr) || length(repstr) == 1
  str = regexprep(str,token,repstr);
else
  pos = strfind(str,token);
  line = find(~cellfun('isempty',pos),1);
  if isempty(line), return;end
  pos = pos{line};
  str = regexprep(str,token,repstr{1});
  str = [str(1:line-1) ...
    {[str{line}(1:pos-1) repstr{1}]} ...
    repstr{2:end-1} ...
    {[repstr{end} str{line}(pos+length(token)+1:end)]} ...
    str(line+1:end)];
end
  
