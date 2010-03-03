function import_gui_cs(wzrd)
% page for setting crystall geometry


setappdata(wzrd,'cs_count',1);

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);
ph = 270;

this_page = get_panel(w,h,ph);
handles = getappdata(wzrd,'handles');
handles.pages = [handles.pages,this_page];
setappdata(this_page,'pagename','Set Crystal Geometry');

set(this_page,'visible','off');

mineral = uibuttongroup('title','Mineral',...
  'Parent',this_page,...
  'units','pixels','position',[0 ph - 85 w-20 75]);



handles.mineral = uicontrol(...
  'Style','edit',...
  'Parent',mineral,...
  'BackgroundColor',[1 1 1],...
  'Position',[10 20 w-240 20],...
  'HorizontalAlignment','left',...
  'string','');

uicontrol(...
  'Parent',mineral,...
  'String','Load Cif File',...
  'CallBack',@lookup_mineral,...
  'Position',[w-220 17 100 25]);

uicontrol(...
  'Parent',mineral,...
  'String','Search Web',...
  'CallBack',@searchWeb,...
  'Position',[w-110 17 80 25]);


% uicontrol(...
%   'Parent',mineral,...
%   'String','Save',...
%   'CallBack',@lookup_mineral,...
%   'Position',[380 17 80 25]);

cs = uibuttongroup('title','Crystal Coordinate System',...
  'Parent',this_page,...
  'units','pixels','position',[0 ph-260 w-20 150]);

uicontrol(...
 'Parent',cs,...
  'String','Laue Group',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 95 100 15]);

handles.crystal = uicontrol(...
  'Parent',cs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[105 95 225 20],...
  'String',blanks(0),...
  'Style','popup',...
  'CallBack',@update_cs,...
  'String',symmetries,...
  'Value',1);

handles.axis_alignment = uicontrol(...
  'Parent',cs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[345 95 w-380 20],...
  'String',blanks(0),...
  'Style','popup',...
  'CallBack',@update_cs,...
  'String',{'m parallel x','m parallel y'},...
  'Value',1);

uicontrol(...
  'Parent',cs,...
  'String','Axis Length',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 55 100 15]);
uicontrol(...
  'Parent',cs,...
  'String','Axis Angle',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 20 100 15]);

axis = {'a','b','c'};
angle=  {'alpha', 'beta', 'gamma'};
for k=1:3
  uicontrol(...
    'Parent',cs,...
    'String',axis{k},...
    'HitTest','off',...
    'Style','text',...
    'HorizontalAlignment','right',...
    'Position',[130+120*(k-1) 55 30 15]);
  uicontrol(...
    'Parent',cs,...
    'String',angle{k},...
    'HitTest','off',...
    'Style','text',...
    'HorizontalAlignment','right',...
    'Position',[110+120*(k-1) 20 50 15]);
  handles.axis{k} = uicontrol(...
    'Parent',cs,...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Position',[165+120*(k-1) 50 60 25],...
    'String',blanks(0),...
    'Style','edit');
  handles.angle{k} = uicontrol(...
    'Parent',cs,...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Position',[165+120*(k-1) 15 60 25],...
    'String',blanks(0),...
    'Style','edit');
end

setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ---------------- Callbacks --------------------------------

function goto_callback(varargin)

get_cs(gcbf);


function leave_callback(varargin)

set_cs(gcbf);


function update_cs(varargin)

set_cs(gcbf);
get_cs(gcbf);


function lookup_mineral(varargin)

handles = getappdata(gcbf,'handles');
data = getappdata(gcbf,'data');
cs_counter = getappdata(gcbf,'cs_count');

name = get(handles.mineral,'string');

[fname,pathName] = uigetfile(fullfile(get_mtex_option('cif_path') ,'*.cif'),'Select cif File');
name = [pathName,fname];

if fname ~= 0
  try
    cs = cif2symmetry(name);
    set(handles.mineral,'string',shrink_name(name));
    if isa(data,'EBSD')
      data(cs_counter) = set(data(cs_counter),'CS',cs);
    else
      data = set(data,'CS',cs);
    end
    setappdata(gcbf,'data',data);
    get_cs(gcbf);  
  catch %#ok<CTCH>
    errordlg(errortext);  
  end 
end

function searchWeb(varargin)

web('http://www.crystallography.net/search.html','-browser')

%% ------------ Private Functions ---------------------------------

function get_cs(wzrd)
% write cs of ebsd / pf to page 

handles = getappdata(wzrd,'handles');
data = getappdata(wzrd,'data');


cs_counter = getappdata(wzrd,'cs_count');
cs = get(data(cs_counter),'CS');

% set page name
if isa(data,'EBSD')
  phase = get(data(cs_counter),'phase');
  pagename = ['Set Crystal Geometry for Phase ' num2str(phase)];
  %eb_comment = char(get(data(cs_counter),'comment'));
  %if length(eb_comment)> 25, eb_comment = eb_comment(1:25); end
  %pagename = [pagename ', ' eb_comment ];
  setappdata(handles.pages(2),'pagename',pagename );
end

csname = strmatch(Laue(cs),symmetries);
set(handles.crystal,'value',csname(1));
 
% set axes
[c, angle] = get_axisangel(cs);
 
if ~isempty(strmatch(Laue(cs),{'-3','-3m','-6','6/mmm'}))
  set(handles.axis_alignment,'string',{'a parallel y','a parallel x'});
  if vector3d(Miller(1,0,0,cs)) == -yvector
    set(handles.axis_alignment,'value',2);
  else
    set(handles.axis_alignment,'value',1);
  end
else
  set(handles.axis_alignment,'value',1);
  set(handles.axis_alignment,'string',{''});
end

for k=1:3 
  set(handles.axis{k},'String',c(k)); 
  set(handles.angle{k},'String',angle{k});
end

set([handles.axis{:} handles.angle{:}], 'Enable', 'on');

if ~strcmp(Laue(cs),{'-1','2/m'})
  set([handles.angle{:}], 'Enable', 'off');
end

if any(strcmp(Laue(cs),{'m-3m','m-3'})),
  set([handles.axis{:}], 'Enable', 'off');
end

set(handles.mineral,'string',get(cs,'mineral'));


function set_cs(wzrd)
% set cs in object (pf/ebsd)

handles = getappdata(wzrd,'handles');
data = getappdata(wzrd,'data');
cs_counter = getappdata(wzrd,'cs_count');

cs = get(handles.crystal,'Value');
cs = symmetries(cs);
cs = strtrim(cs{1}(1:6));
 
for k=1:3 
  axis{k} =  str2double(get(handles.axis{k},'String')); %#ok<AGROW>
  angle{k} =  str2double(get(handles.angle{k},'String')); %#ok<AGROW>
end

mineral = get(handles.mineral,'string');

alignment = get(handles.axis_alignment,'Value');
if alignment == 1
  cs = symmetry(cs,[axis{:}],[angle{:}]*degree,'a||y','mineral',mineral);
else
  cs = symmetry(cs,[axis{:}],[angle{:}]*degree,'a||x','mineral',mineral);
end

if isa(data,'EBSD')
  data(cs_counter) = set(data(cs_counter),'CS',cs);
else
  data = set(data,'CS',cs);
end

setappdata(wzrd,'data',data);

function fname = shrink_name(fname)

[pathname, name, ext] = fileparts(fname);
if strcmp(ext,'.cif'), ext = [];end
if strcmp(pathname,get_mtex_option('cif_path'))
  fname = [name ext];
else
  fname = fullfile(pathname,[name ext]);
end
