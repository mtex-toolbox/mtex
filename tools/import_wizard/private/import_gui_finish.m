function handles = import_gui_finish( handles )

pos = get(handles.wzrd,'Position');
h = pos(4);
w = pos(3);

ph = 270;


%% last page
handles.page5 = get_panel(w,h,ph);
set(handles.page5,'visible','off');

handles.preview = uicontrol(...
  'Parent',handles.page5,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Max',2,...
  'Position',[10 65 w-40 ph-75 ],...
  'String',blanks(0),...
  'Style','edit',...
  'Enable','inactive',...
  'Visible','off');

out = uibuttongroup('title','Output',...
  'Parent',handles.page5,...
  'Visible','off',...
  'units','pixels','position',[0 ph-260 380 45]);

handles.runmfile = uicontrol(...
  'Parent',out,...
  'Style','radio',...
  'String','Generate M-File',...
  'Value',1,...
  'Visible','off',...
  'position',[10 6 130 20]);


uicontrol(...
  'Parent',out,...
  'Style','radio',...
  'String','Generate Workspace Variable',...
  'Value',0,...
  'Visible','off',...
  'position',[160 6 210 20]);
