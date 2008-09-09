function handles = import_gui_data(wzrd)
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

handles.tabs = uitabpanel(...
  'Parent',this_page,...
  'TabPosition','lefttop',...
  'units','pixel',...
  'position',[0,0,w-18,270],...
  'Margins',{[2,2,2,2],'pixels'},...
  'PanelBorderType','beveledout',...
  'Title',{'Pole Figures','EBSD','Background','Defocussing','Defocussing BG'},...
  'FrameBackgroundColor',get(gcf,'color'),...
  'PanelBackgroundColor',get(gcf,'color'),...
  'TitleForegroundColor',[0,0,0]);

panels = getappdata(handles.tabs,'panels');

for i = 1:length(panels)

  handles.listbox(i) = uicontrol(...
    'Parent',panels(i),...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Max',2,...
    'Position',[10 10 w-165 ph-45],...
    'String',blanks(0),...
    'Style','listbox',...
    'Value',1);
  
  handles.add = uicontrol(...
    'Parent',panels(i),...
    'String','Add File',...
    'Callback',{@addData,i},...
    'Position',[w-145 ph-60 110 25]);

  handles.del = uicontrol(...
    'Parent',panels(i),...
    'String','Remove File',...
    'CallBack',{@delData,i},...
    'Position',[w-145 ph-90 110 25]);

end

setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ------------- Callbacks -----------------------------------------

function goto_callback(varargin)

data = getappdata(gcbf,'data');
handles = getappdata(gcbf,'handles');
if ~isempty(getappdata(handles.listbox(1),'data'))
  setappdata(handles.listbox(1),'data',data);
else
  setappdata(handles.listbox(2),'data',data);
end

function leave_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;
pf = getappdata(lb(1),'data');
ebsd = getappdata(lb(2),'data');
if isempty(pf) 
  if isempty(ebsd)
    error('Add some data files to be imported!');
  else
    setappdata(gcbf,'data',ebsd);
    handles.pages = handles.ebsd_pages;
  end
elseif isempty(ebsd) 
  
  % pole figure correction
  bg = getappdata(lb(2),'data');
  def = getappdata(lb(3),'data');
  def_bg = getappdata(lb(4),'data');
  pf = correct(pf,'bg',bg,'def',def,'def_bg',def_bg);

  setappdata(gcbf,'data',pf);
  handles.pages = handles.pf_pages;
else
  error('You can only import either Pole Figure Data or EBSD data! Clear one list to proceed!');
end

setappdata(gcbf,'handles',handles);

function addData(h,event,t) %#ok<INUSL>

handles = getappdata(gcbf,'handles');
type = {'PoleFigure','EBSD','PoleFigure','PoleFigure','PoleFigure'};
addfile(handles.listbox(t),type{t});


function delData(h,event,t)  %#ok<INUSL>

handles = getappdata(gcbf,'handles');
delfile(handles.listbox(t));

