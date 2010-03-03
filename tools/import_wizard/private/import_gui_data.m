function handles = import_gui_data(wzrd,varargin)
% page for adding files to be imported

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);
ph = 270;

this_page = get_panel(w,h,ph);

handles = getappdata(wzrd,'handles');
handles.pages = [handles.pages,this_page];
setappdata(this_page,'pagename','Select Data Files');

set(this_page,'visible','off');

if check_option(varargin,'EBSD')
  select = 2;
elseif check_option(varargin,'ODF')
  select = 3;
else
  select = 1;
end

handles.tabs = uitabpanel(...
  'Parent',this_page,...
  'TabPosition','lefttop',...
  'units','pixel',...
  'position',[0,0,w-18,260],...
  'Margins',{[2,2,2,2],'pixels'},...
  'PanelBorderType','beveledout',...
  'Title',{'Pole Figures','EBSD','ODF'},... %,'Background','Defocussing','Defocussing BG'},...
  'FrameBackgroundColor',get(gcf,'color'),...
  'PanelBackgroundColor',get(gcf,'color'),...
  'TitleForegroundColor',[0,0,0],...
  'selectedItem',select);

panels = getappdata(handles.tabs,'panels');


handles.tabs_pf = uitabpanel(...
  'Parent',panels(1),...
  'Style','popup',...
  'TabPosition','lefttop',...
  'units','pixel',...
  'position',[2,2,w-155,230],...
  'Margins',{[0,0,-10,0],'pixels'},...
  'PanelBorderType','beveledout',...
  'Title',{'Data','Background','Defocussing','Defocussing BG'},...
  'FrameBackgroundColor',get(gcf,'color'),...
  'PanelBackgroundColor',get(gcf,'color'),...
  'TitleForegroundColor',[0,0,0],...
  'selectedItem',1);

handles.datapane = [getappdata(handles.tabs_pf,'panels') panels(2:end)];

handles.importcpr = uicontrol(...
  'Parent',panels(2),...
  'String','Import from Project',...
  'CallBack',{@importProjectSettings},...
  'Position',[w-145 ph-150 110 25]);


handles.add = uicontrol(...
  'Parent',this_page,...
  'String','Add File',...
  'Callback',{@addData},...
  'Position',[w-145 ph-80 110 25]);
  
handles.del = uicontrol(...
  'Parent',this_page,...
  'String','Remove File',...
  'CallBack',{@delData},...
  'Position',[w-145 ph-110 110 25]);


paneltypes = {'PoleFigure','PoleFigure','PoleFigure','PoleFigure','EBSD','ODF'};

for k = 1:length(handles.datapane)  
  handles.listbox(k) = uicontrol(...
    'Parent',handles.datapane(k),...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Max',2,...
    'Position',[9 10 w-165 ph-75],...
    'String',blanks(0),...
    'Style','listbox',...
    'tag',paneltypes{k},...
    'Value',1);
end

for k=5:6
  set(handles.listbox(k),'Position',[9 10 w-165 ph-65])
end


setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ------------- Callbacks -----------------------------------------

function goto_callback(varargin)

data = getappdata(gcbf,'data');
handles = getappdata(gcbf,'handles');
if ~isempty(getappdata(handles.listbox(1),'data'))
  
  % for pole figures take care not to change the data  
  pf = getappdata(handles.listbox(1),'data');
  d = get(pf,'intensities');
  data = set(data,'intensities',d);
  setappdata(handles.listbox(1),'data',data);

elseif ~isempty(getappdata(handles.listbox(2),'data'))
  setappdata(handles.listbox(2),'data',data);  
else  
  setappdata(handles.listbox(3),'data',data);  
end

function leave_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;

pf = getappdata(lb(1),'data');
ebsd = getappdata(lb(5),'data');
odf = getappdata(lb(6),'data');

s = ~isempty(pf) + ~isempty(ebsd) + ~isempty(odf);
if s == 0
  error('Add some data files to be imported!');
elseif s > 1
  error('You can only import one type of data! Clear one list to proceed!');
end

if ~isempty(ebsd) 
  
  setappdata(gcbf,'data',ebsd);
  handles.pages = handles.ebsd_pages;
  
elseif ~isempty(odf)
  
  setappdata(gcbf,'data',odf);
  handles.pages = handles.odf_pages;
  
elseif ~isempty(pf) 
  
  % pole figure correction
  bg = getappdata(lb(2),'data');
  def = getappdata(lb(3),'data');
  def_bg = getappdata(lb(4),'data');
  pf = correct(pf,'bg',bg,'def',def,'defbg',def_bg);

  setappdata(gcbf,'data',pf);
  handles.pages = handles.pf_pages;

end

setappdata(gcbf,'handles',handles);

function addData(h,event,t) %#ok<INUSL>

handles = getappdata(gcbf,'handles');
pane = handles.datapane;
t= find(strcmpi(get(pane,'visible'),'on'),1,'last');
addfile(handles.listbox(t(end)),get(handles.listbox(t(end)),'tag'));


function delData(h,event)  %#ok<INUSL>

handles = getappdata(gcbf,'handles');
pane = handles.datapane;
t= find(strcmpi(get(pane,'visible'),'on'),1,'last');
delfile(handles.listbox(t(end)));


function importProjectSettings(h,event)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;
ebsd = getappdata(lb(5),'data');


if ~isempty(ebsd) 
  try
    [file path] = uigetfile('*.cpr','Select associated CPR Project-file');
    if file ~=0
      phases = cprproject_read(fullfile(path,file));
      ebsd = set(ebsd,'CS',phases(get(ebsd,'phase')));  
      setappdata(lb(5),'data',ebsd);
      msgbox('Phases information successfully loaded!')
    end
  catch
    errordlg('failed to import Project file')
  end
end
