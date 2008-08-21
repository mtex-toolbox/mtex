function  xrdml_help( varargin )
%xrdml gui helper for import wizard

global handles
global appdata

if nargin>0  && ischar(varargin{1}) && ~strcmp(varargin{1},'file')
  feval(varargin{:});
else
  appdata.old = appdata;
  if strcmp(appdata.assert_assistance,'None')
    appdata.assert_assistance = questdlg('XRMDL data is usually provided in 4 parts, do you want assistance regarding import proceeding?','XRDML Import');
    if strcmp(appdata.assert_assistance,'Yes')
      modifie_handles;
      
      appdata.f{1} = appdata.filename;
      appdata.pf_merge{1} = appdata.pf;
      appdata.ipf_merge{1} = appdata.ipf;
      for i=2:4 
         appdata.pf_merge{i} = [];
         appdata.ipf_merge{i} = 0;
      end
    end
  end
  if strcmp(appdata.assert_assistance,'Yes')
  %mainframe
    handles.xrdml_frame = import_frame('type', 'XRDML','width',670);
    handles = import_gui_xrdml(handles);
    
    for type=1:length(appdata.f)
      set(handles.list{type}, 'String', path2filename(appdata.f{type}));    
    end
  end 
end

%% ------------ finish callback -------------------------------------------
function finish

global appdata
global handles

check_gui
if ~isempty(appdata.pf)
  for i=2:4
    if length(appdata.pf_merge{i}) ~= length(appdata.pf_merge{1})
      warndlg('Polefigure assignment is unequal!')
      return;
    end
  end
  
  handles_proceed = [handles.proceed handles.cancel];
  set(handles_proceed,'Visible','off');
  drawnow; pause(0.001);

  try
    sb = statusbar(handles.xrdml_frame,' Merge PoleFigures ...');
    set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',length(appdata.pf_merge{1}), 'Value',0, 'StringPainted','on')
  catch end
  
  for i=1:length(appdata.pf_merge{1})
    appdata.pf(i) = correct( appdata.pf_merge{1}(i),'bg',appdata.pf_merge{2}(i),'def',appdata.pf_merge{3}(i),'def_bg',appdata.pf_merge{4}(i));
    try, set(sb.ProgressBar,'Value',i);catch end
  end
  
  try, statusbar(handles.xrdml_frame);catch,end;  
end 
close

%% ------------ cancel action ---------------------------------------------
function cancel 
global handles
global appdata

appdata = appdata.old;
check_gui

close

%% ------------ is every thing ok -----------------------------------------
function check_gui
global appdata
global handles

if isempty([appdata.f{:}])
  appdata.assert_assistance= 'None';
  
  modifie_handles;
  
  appdata.filename = [];
  appdata.interface = '';
  appdata.options = {};
  appdata.pf = [];
  appdata.ipf = 0;
  
  for i=1:4
    appdata.pf_merge{i} = [];
    appdata.ipf_merge{i} = 0;
  end
else 
  set(handles.listbox, 'String',path2filename( appdata.f{1}));
end

%% ------------ data import callback --------------------------------------
function add(type)
global handles
global appdata

[fname,pathname] = uigetfile( mtexfilefilter(),...
  'Select Data files',...
  'MultiSelect', 'on',appdata.workpath);

if ~iscellstr(fname)
  if fname ~= 0
    fn = {fname};
  else
    return;
  end
else
  fn = fname;
end;

if ~isempty(appdata.interface)
  interf = {'interface',appdata.interface};
else
  interf = {};
end


handles_proceed = [handles.proceed handles.cancel];
set(handles_proceed,'Visible','off');
drawnow; pause(0.001);

try
  sb = statusbar(handles.xrdml_frame,' Importing PoleFigure ...');
  set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',length(fn), 'Value',0, 'StringPainted','on')
catch end

check_warn(strcat(pathname,fn{1}),type)
  
for i=1:length(fn) 
  try
    [npf,appdata.interface,appdata.options,ipf] = ...
      loadPoleFigure(strcat(pathname,fn(i)),interf{:},appdata.options{:});
  catch
     errordlg(errortext);
      break;
  end
  try, set(sb.ProgressBar,'Value',i);catch end
  
  %pole figures
  appdata.pf_merge{type} =  [appdata.pf_merge{type},npf];
  appdata.workpath = pathname;
  appdata.f{type} =  [appdata.f{type}, strcat(pathname,fn(i))];
  appdata.ipf_merge{type} = [appdata.ipf_merge{type},ipf];
  updatelist(type);
  
  if type==1,  appdata.pf = [appdata.pf,npf]; end
end

try, statusbar(handles.xrdml_frame);catch,end;

set(handles_proceed,'Visible','on');
drawnow; pause(0.001);

%% ------------ deleting data callback ------------------------------------
function del(type)
global handles
global appdata

if ~isempty(appdata.pf_merge{type})
  index_selected = get(handles.list{type},'Value');
  cpf = cumsum(appdata.ipf_merge{type});
  ipf = [];
  for i = 1:length(index_selected)
    ipf = [ipf,1+cpf(index_selected(i)):cpf(index_selected(i)+1)];
  end
  
  % remove pole figure
  if type==1, appdata.pf(ipf) = []; end
  appdata.pf_merge{type}(ipf) = [];
  appdata.ipf_merge{type}(1+index_selected) = [];
    
  if iscellstr(appdata.f{type})
    appdata.f{type}(:,index_selected(:))='';
  else
    appdata.f{type} = '';
  end;
  
  selected = min([index_selected,length(appdata.f{type})]);
  
  set(handles.list{type},'Value',selected);  
  updatelist(type)

end

%% ------------ update listbox --------------------------------------------
function updatelist(type)
global handles
global appdata

set(handles.list{type}, 'String', path2filename(appdata.f{type}));
if type==1,set(handles.listbox, 'String',path2filename( appdata.f{1}));end
set(handles.list{type},'Value',1);
drawnow;

function check_warn(file,type)
try
  doc = xmlread(file);
  xRoot = doc.getDocumentElement;
  mtype = xRoot.getElementsByTagName('xrdMeasurement').item(0).getAttribute('measurementType');
  
  w=0;
  switch type
    case 1
      if ~findstr(mtype,'background') && ~findstr(mtype,'background'), w=1; end
    case 2
      if findstr(mtype,'background'), w=1;end
    case 3
      if findstr(mtype,'defocusing'), w=1;end
    case 4
      if findstr(mtype,'background'), w=1;end
  end
  if ~w, warndlg('Data seems not to fit requirements, please be sure about correctness.');end
end

%% ------------ modify handles of import_wizard ---------------------------
function modifie_handles
global handles
global appdata

if strcmp(appdata.assert_assistance, 'Yes');
  set(handles.listbox,'Enable','off');
  set(handles.add,'Callback', 'xrdml_help');
  set(handles.add,'String','Modify');
  set(handles.del,'Parent',handles.wzrd);
  set(handles.del,'Visible','off');    
else
  set(handles.listbox,'Enable','on');
  set(handles.listbox, 'String',blanks(0));
  set(handles.add,'String','Add File');
  set(handles.add,'Callback','import_wizard_PoleFigure(''addData'')');  
  set(handles.del,'Parent',handles.page1);
  set(handles.del,'Visible','on');
end
