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
    handles.xrml_frame = import_frame('type', 'XRDML','width',670);
    handles = import_gui_xrdml(handles);
    
    for type=1:length(appdata.f)
      set(handles.list{type}, 'String', path2filename(appdata.f{type}));    
    end
  end 
end

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

  for i=1:length(appdata.pf_merge{1})
    appdata.pf(i) = xrdml_merge([appdata.pf_merge{1}(i),appdata.pf_merge{2}(i),appdata.pf_merge{3}(i),appdata.pf_merge{4}(i)]);
  end
end 
close

function cancel 
global handles
global appdata

appdata = appdata.old;
check_gui

close

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

try
  [npf,appdata.interface,appdata.options,ipf] = ...
    loadPoleFigure(strcat(pathname,fn(:)),interf{:},appdata.options{:});
     
  check_warn(strcat(pathname,fn{1}),type)
       
  %pole figures
  appdata.pf_merge{type} =  [appdata.pf_merge{type},npf];
  appdata.workpath = pathname;
  appdata.f{type} =  [appdata.f{type}, strcat(pathname,fn)];
  appdata.ipf_merge{type} = [appdata.ipf_merge{type},ipf];
  
  if type==1,  appdata.pf = [appdata.pf,npf]; end
catch
  errordlg(errortext);
end
updatelist(type)


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
  
function updatelist(type)
global handles
global appdata

set(handles.list{type}, 'String', path2filename(appdata.f{type}));
if type==1,set(handles.listbox, 'String',path2filename( appdata.f{1}));end
set(handles.list{type},'Value',1);

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
