function wzrd = import_gui_xrdml(varargin )

% empty wizard
wzrd = import_gui_empty(varargin{:});

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);

ph = 300;

handles = getappdata(wzrd,'handles');

%% page title
handles.name = uicontrol(...
'Parent',wzrd,...
 'FontSize',12,...
 'ForegroundColor',[0.3 0.3 0.3],...
 'FontWeight','bold',...
 'BackgroundColor',[1 1 1],...
 'HorizontalAlignment','left',...
 'Position',[10 h-37 w-150 20],...
 'Style','text',...
 'HandleVisibility','off',...
 'HitTest','off');


%%
descriptor ={'Texture pole figure',...
  'Texture background measurement',...
  'Texture defocusing measurement',...
  'Texture defocusing background measurement'};

%%
for i=1:4 
uicontrol('Style','Text',...
  'FontWeight','bold',...
  'HorizontalAlignment','left',...
  'Position',[20*(8*i-7) ph 150 30],...
  'string',descriptor{i});
handles.list{i} = uicontrol(...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Max',2,...
  'Position',[-140+160*i 70 150 ph-110],...
  'String',blanks(0),...
  'Style','listbox',...
  'Value',1);

handles.addt = uicontrol(...
  'String','Add File',...
  'Callback',{@add,i},...
  'Position',[-140+160*i ph-35 75 25]);

handles.delt = uicontrol(...
  'String','Remove File',...
  'CallBack',{@del,i},...
  'Position',[-65+160*i ph-35 75 25]);
end

%%
handles.ok = uicontrol('Style','PushButton','String','Proceed ',...
  'Position',[w-90,10,70,25],'CallBack',@finish);

handles.cancel = uicontrol('Style','PushButton','String','Cancel ',...
  'Position',[w-160,10,70,25],'CallBack',@cancel);

uipanel('units','pixel',...
  'HighlightColor',[0 0 0],...
  'Position',[10 50 w-20 1]);

handles.proceed = [handles.ok,handles.cancel];

setappdata(wzrd,'handles',handles);


%% ------------ Callbacks ---------------------------------------------


function add(x,y,type) %#ok<INUSL>

handles = getappdata(gcbf,'handles');
addfile(gcbf,handles.list{type});


function del(x,y,type)  %#ok<INUSL>

handles = getappdata(gcbf,'handles');
delfile(handles.list{type});


function finish(varargin)

handles = getappdata(gcbf,'handles');

% get assi data
for i = 1:4, assi{i} = getappdata(handles.list{i});end

% are there any data
if isempty(assi{1}.data), return;end

% correct pole figures  
try
  data = correct(assi{1}.data,'bg',assi{2}.data,...
    'def',assi{3}.data,'def_bg',assi{4}.data);
catch
  errordlg(errortext);
  return
end

% export data to import wizard
wzrd = getappdata(gcbf,'wzrd');
setappdata(wzrd,'assi',assi);
handles = getappdata(wzrd,'handles');
fn = fields(assi{i});
for i = 1:length(fn)
  setappdata(handles.listbox,fn{i},assi{1}.(fn{i}));
end
set(handles.listbox,'String',path2filename(assi{1}.filename));
setappdata(handles.listbox,'data',data);

close(gcbf)


function cancel(varargin)

close(gcbf)



