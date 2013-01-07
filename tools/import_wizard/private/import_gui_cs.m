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
  'units','pixels','position',[0 ph - 120 w-20 115],...
  'SelectionChangeFcn',@update_cs);


handles.indexed(1) = uicontrol(...
  'Parent',mineral,...
  'String','Indexed',...
  'Style','radio',...
  'Position',[10 75 150 15]);

handles.indexed(2) = uicontrol(...
  'Parent',mineral,...
  'String','Not Indexed',...
  'Style','radio',...
  'Position',[95 75 150 15]);


uicontrol(...
  'Parent',mineral,...
  'String','mineral name',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 45 100 15]);


handles.mineral = uicontrol(...
  'Style','edit',...
  'Parent',mineral,...
  'BackgroundColor',[1 1 1],...
  'Position',[110 45 180 20],...
  'HorizontalAlignment','left',...
  'string','');

uicontrol(...
  'Parent',mineral,...
  'String','plotting color',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 15 130 15]);

handles.color = uicontrol(...
  'Parent',mineral,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[110 15 180 20],...
  'String',blanks(0),...
  'Style','popup',...
  'CallBack',@update_cs,...
  'String',getpref('mtex','EBSDColorNames'),...
  'Value',1);



uicontrol(...
  'Parent',mineral,...
  'String','Load Cif File',...
  'CallBack',@lookup_mineral,...
  'Position',[350 37 100 25]);




% uicontrol(...
%   'Parent',mineral,...
%   'String','Save',...
%   'CallBack',@lookup_mineral,...
%   'Position',[380 17 80 25]);

cs = uibuttongroup('title','Crystal Coordinate System',...
  'Parent',this_page,...
  'units','pixels','position',[0 ph-269 w-20 135],...
  'SelectionChangeFcn',@update_cs);

handles.csframe = cs;

uicontrol(...
  'Parent',cs,...
  'String','Laue Group',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 85 80 15]);

handles.crystal = uicontrol(...
  'Parent',cs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[95 85 180 20],...
  'String',blanks(0),...
  'Style','popup',...
  'CallBack',@update_cs,...
  'String',symmetries,...
  'Value',1);

handles.axis_alignment1 = uicontrol(...
  'Parent',cs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[290 85 80 20],...
  'String',blanks(0),...
  'Style','popup',...
  'String',alignments,...
  'Value',1);

handles.axis_alignment2 = uicontrol(...
  'Parent',cs,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Position',[385 85 80 20],...
  'String',blanks(0),...
  'Style','popup',...
  'String',alignments,...
  'Value',1);

uicontrol(...
  'Parent',cs,...
  'String','Axis Length',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 50 100 15]);
uicontrol(...
  'Parent',cs,...
  'String','Axis Angle',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 15 100 15]);

axis = {'a','b','c'};
angle=  {'alpha', 'beta', 'gamma'};
for k=1:3
  uicontrol(...
    'Parent',cs,...
    'String',axis{k},...
    'HitTest','off',...
    'Style','text',...
    'HorizontalAlignment','right',...
    'Position',[130+120*(k-1) 50 30 15]);
  uicontrol(...
    'Parent',cs,...
    'String',angle{k},...
    'HitTest','off',...
    'Style','text',...
    'HorizontalAlignment','right',...
    'Position',[110+120*(k-1) 15 50 15]);
  handles.axis{k} = uicontrol(...
    'Parent',cs,...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Position',[165+120*(k-1) 45 60 25],...
    'String',blanks(0),...
    'Style','edit');
  handles.angle{k} = uicontrol(...
    'Parent',cs,...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Position',[165+120*(k-1) 10 60 25],...
    'String',blanks(0),...
    'Style','edit');
end

setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ---------------- Callbacks --------------------------------

function goto_callback(varargin)

handles = getappdata(gcf,'handles');

if isa(getappdata(gcf,'data'),'EBSD')
  set(handles.indexed,'enable','on');
else
  set(handles.indexed,'enable','off');  
end

get_cs(gcbf);


function leave_callback(varargin)

handles = getappdata(gcf,'handles');

if isa(getappdata(gcf,'data'),'EBSD')
  set(handles.indexed,'enable','on');
else
  set(handles.indexed,'enable','off');  
end

set_cs(gcbf);


function update_cs(varargin)

set_cs(gcbf);
get_cs(gcbf);


function lookup_mineral(varargin)

handles = getappdata(gcbf,'handles');
data = getappdata(gcbf,'data');

name = get(handles.mineral,'string');

try
  assert(~isempty(name));
  cif2symmetry(name);
catch   %#ok<CTCH>
  [fname,pathName] = uigetfile(fullfile(mtexCifPath,'*.cif'),'Select cif File');
  name = [pathName,fname];
end

if name ~= 0
  try
    cs = loadCIF(name);
    set(handles.mineral,'string',shrink_name(name));
    if isa(data,'EBSD')
      
       ph = unique(get(data,'phases'));
       cs_counter = getappdata(gcf,'cs_count');
       csCell = get(data,'CSCell');
       phase = ph(cs_counter);
       csCell{phase} = cs;
      
      data = set(data,'CS',csCell,'noTrafo');
    else
      data = set(data,'CS',cs,'noTrafo');
    end
    setappdata(gcbf,'data',data);
    get_cs(gcbf);
  catch %#ok<CTCH>
    errordlg(errortext);
  end
end


%% ------------ Private Functions ---------------------------------

function get_cs(wzrd)
% write cs of ebsd / pf to page

handles = getappdata(gcf,'handles');
data = getappdata(gcf,'data');

if isa(data,'cell')
  data = data{1};
end

% set page name
if isa(data,'EBSD')
  phase = get(data,'phaseMap');
  cs_counter = getappdata(gcf,'cs_count');
  CS = get(data,'CSCell');
  cs = CS{cs_counter};
  pagename = ['Set Crystal Geometry for Phase ' num2str(phase(cs_counter))];
  setappdata(handles.pages(3),'pagename',pagename );
else
  cs = get(data,'CS');
end

Childs = get(handles.csframe,'Children');

if ischar(cs)
  
  set(handles.indexed(1),'Value',0);
  set(handles.indexed(2),'Value',1);
  
  set(Childs,'Enable','off');
  set(handles.mineral,'Enable','off');
  set(handles.color,'Enable','off');
  
  set(handles.mineral,'string',cs);
  
else
  
  set(handles.indexed(1),'Value',1);
  set(handles.indexed(2),'Value',0);
  
  csname = strmatch(Laue(cs),symmetries);
  set(handles.crystal,'value',csname(1));
  
  color = get(cs,'color');
  color = strmatch(color,getpref('mtex','EBSDColorNames'));
  set(handles.color,'value',color(1));
  
  set(Childs,'Enable','on');
  set(handles.mineral,'Enable','on');
  set(handles.color,'Enable','on');
  
  % set alignment
  al = [get(cs,'alignment'),{'',''}];
  set(handles.axis_alignment1,'value',find(strcmp(alignments,al{1})));
  set(handles.axis_alignment2,'value',find(strcmp(alignments,al{2})));
  
  % set axes
  [c, angle] = get_axisangel(cs);
  
  for k=1:3
    set(handles.axis{k},'String',c(k));
    set(handles.angle{k},'String',angle{k});
  end
  
  % set whether axes and angles can be changed
  set([handles.axis{:} handles.angle{:}], 'Enable', 'on');
  
  if ~strcmp(Laue(cs),{'-1','2/m'})
    set([handles.angle{:}], 'Enable', 'off');
  end
  
  % set mineral
  set(handles.mineral,'string',get(cs,'mineral'));
end


function set_cs(wzrd)
% set cs in object (pf/ebsd)

handles = getappdata(wzrd,'handles');
data = getappdata(wzrd,'data');


% if not indexed
if isa(data,'EBSD') && get(handles.indexed(2),'Value')% ||...
%    any(strfind(lower(mineral),'indexed')) && any(strfind(lower(mineral),'not')))

  cs = 'not indexed';

else % indexed data
  
  cs = get(handles.crystal,'Value');
  cs = symmetries(cs);
  cs = strtrim(cs{1}(1:6));

  for k=1:3
    axis{k}  =  str2double(get(handles.axis{k},'String')); %#ok<AGROW>
    angle{k} =  str2double(get(handles.angle{k},'String')); %#ok<AGROW>
  end

  mineral = get(handles.mineral,'string');

  al1 = get(handles.axis_alignment1,'Value');
  al2 = get(handles.axis_alignment2,'Value');
  al = alignments;

  co = getpref('mtex','EBSDColorNames');
  co = co{get(handles.color,'Value')};
  try
    cs = symmetry(cs,[axis{:}],[angle{:}]*degree,al{al1},al{al2},...
      'mineral',mineral,'color',co);
  catch %#ok<CTCH>
    cs = symmetry(cs,[axis{:}],[angle{:}]*degree,'mineral',mineral,'color',co);
  end
end
  
if isa(data,'EBSD') 
  cs_counter = getappdata(gcf,'cs_count');
  CS = get(data,'CSCell');  
  CS{cs_counter} = cs;
  cs = CS;
end

if isa(data,'cell')
  data = cellfun(@(d) set(d,'CS',cs),data,'UniformOutput',false);
else
  data = set(data,'CS',cs,'noTrafo');
end

setappdata(wzrd,'data',data);


function fname = shrink_name(fname)

[pathname, name, ext] = fileparts(fname);
if strcmp(ext,'.cif'), ext = [];end
if strcmp(pathname,mtexCifPath)
  fname = [name ext];
else
  fname = fullfile(pathname,[name ext]);
end

function al = alignments

xyz = {'X','Y','Z'};
abc = {'a','b','c','a*','b*','c*'};

al = {};
for ix = 1:3
  al = [al cellfun(@(a) [xyz{ix},'||',a],abc,'UniformOutput',false)]; %#ok<AGROW>
end
al = [{''} al];

function co = colorOrder

co = {'','none','blue','green','red','cyan','magenta','yellow','white','black'};
