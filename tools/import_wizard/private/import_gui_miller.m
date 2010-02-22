function import_gui_miller(wzrd)
% page for Miller indece input

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);
ph = 270;

this_page = get_panel(w,h,ph);
handles = getappdata(wzrd,'handles');
handles.pages = [handles.pages,this_page];
setappdata(this_page,'pagename','Set Miller Indice');

set(this_page,'visible','off');

uicontrol(...
  'String','Imported Pole Figure Data Sets',...
  'Parent',this_page,...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 ph-25 200 15]);

handles.listbox_miller = uicontrol(...
  'Parent',this_page,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Max',2,...
  'Position',[15 37 w-225 ph-70],...
  'String',blanks(0),...
  'Style','listbox',...
  'Max',1,...
  'Callback',@update_miller,...
  'Value',1);

mi = uibuttongroup('title','Miller Indece',...
  'Parent',this_page,...
  'units','pixels','position',[w-190 ph-160 170 150]);

ind = {'h','k','i','l'};
for k=1:4
uicontrol(...
 'Parent',mi,...
  'String',ind{k},...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','right',...
  'Position',[10 132-30*k 10 15]);
handles.miller{k} = uicontrol(...
  'Parent',mi,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[30 130-30*k 120 22],...
  'String',blanks(0),...
  'Callback',@update_indices,...
  'Style','edit');
end

sc = uibuttongroup('title','Structure Coefficients',...
  'Parent',this_page,...
  'units','pixels','position',[310 ph-230 170 55]);

uicontrol(...
 'Parent',sc,...
  'String','c',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','right',...
  'Position',[10 10 10 15]);

handles.structur = uicontrol(...
  'Parent',sc,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[30 10 120 22],...
  'String',blanks(0),...
  'Callback',@update_indices,...
  'Style','edit');

uicontrol(...
  'String',['For superposed pole figures seperate multiple Miller indece ', ...
  'and structure coefficients by space!'],...
  'Parent',this_page,...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 0 w-20 30]);

setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ------------- Callbacks -----------------------------------------

function goto_callback(varargin)

setup_polefigurelist(gcbf);
get_hkil(gcbf);

function leave_callback(varargin)

try
  set_hkil(gcbf);
catch
  error('There must be the same number of hkli and structure coefficients.');
end

function update_miller(varargin) 

get_hkil(gcbf);
setup_polefigurelist(gcbf);

function update_indices(varargin)

try
  set_hkil(gcbf);
  get_hkil(gcbf);
catch
end
setup_polefigurelist(gcbf);


%% ------------ private functions ------------------------------------

function get_hkil(wzrd)
% write hkil to page

handles = getappdata(wzrd,'handles');
data = getappdata(wzrd,'data');

ip =  get(handles.listbox_miller,'Value');

set(handles.miller{3}, 'Enable','on');

m = get(data(ip),'Miller');

hkil={'h','k','i','l'};
for k=1:4
  set(handles.miller{k}, 'String', int2str(get(m,hkil{k})));
end

if ~any(strcmp(Laue(get(data,'CS')),{'-3m','-3','6/m','6/mmm'}))
  set(handles.miller{3}, 'Enable','off');
end

set(handles.structur, 'String', xnum2str(get(data(ip),'c')));



function set_hkil(wzrd)
% set hkli in pole figure object

handles = getappdata(wzrd,'handles');
data = getappdata(wzrd,'data');
ip =  get(handles.listbox_miller,'Value');

h = str2num(get(handles.miller{1}, 'String')); %#ok<ST2NM>
k = str2num(get(handles.miller{2}, 'String')); %#ok<ST2NM>
l = str2num(get(handles.miller{4}, 'String')); %#ok<ST2NM>
c = str2num(get(handles.structur, 'String')); %#ok<ST2NM>

assert(all([length(h),length(k),length(l)] == length(c)));

data(ip) = set(data(ip),'h',Miller(h,k,l,get(data,'CS')));
data(ip) = set(data(ip),'c',c);

setappdata(wzrd,'data',data);
 

function setup_polefigurelist(wzrd)
% fill list of pole figures

handles = getappdata(wzrd,'handles');
data = getappdata(wzrd,'data');

for i=1:length(data) 
 m{i} = char(get(data(i),'Miller'));  
 p{i} = ['  ',get(data(i),'comment')];
end
pflist = cellstr([strvcat(m),strvcat(p)]);

set(handles.listbox_miller, 'String', pflist);
n = get(handles.listbox_miller, 'Value');
if n <= 0 || n > length(data)
  set(handles.listbox_miller, 'Value', 1);
end
