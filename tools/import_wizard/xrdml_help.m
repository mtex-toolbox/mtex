function  xrdml_help(wzrd,varargin)
%xrdml gui helper for import wizard

% remove add and del buttons
modifie_handles(wzrd);


wzrd_handles = getappdata(wzrd,'handles');

% get assi data
assi = getappdata(wzrd,'assi');
if isempty(assi)
  assi = getappdata(wzrd_handles.listbox);
  assi = {assi,assi};
  assi{2}.data = [];
  assi{2}.idata = [];
  assi{2}.filename = {};
  assi = {assi{1},assi{2},assi{2},assi{2}};
end

%mainframe
xrdml_wzrd = import_gui_xrdml('type', 'XRDML','width',670);
setappdata(xrdml_wzrd,'wzrd',wzrd);

% set assi data
handles = getappdata(xrdml_wzrd,'handles');
assifields = fields(assi{1});
for i = 1:4
  set(handles.list{i}, 'String',path2filename( assi{i}.filename));
  for f = 1:length(assifields)
    setappdata(handles.list{i},assifields{f},assi{i}.(assifields{f}));
  end
end

drawnow;




%% ------------ modify handles of import_wizard ---------------------------
function modifie_handles(wzrd)

handles = getappdata(wzrd,'handles');

if strcmp(getappdata(wzrd,'assert_assistance'),'Yes')
  set(handles.listbox,'Enable','off');
  % store old callback
  setappdata(wzrd,'add_callback',get(handles.add,'Callback'));  
  % set new one
  set(handles.add,'Callback', 'xrdml_help');
  set(handles.add,'String','Modify');
%  set(handles.del,'Parent',handles.wzrd);
  set(handles.del,'Visible','off');    
else
  set(handles.listbox,'Enable','on');
  set(handles.listbox, 'String',blanks(0));
  set(handles.add,'String','Add File');
  % restore old callback
  set(handles.add,'Callback',getappdata(wzrd,'add_callback'));  
%  set(handles.del,'Parent',handles.page1);
  set(handles.del,'Visible','on');
end
