function import_wizard_EBSD( varargin )
% import helper for EBSD data
%

if nargin >0  && ischar(varargin{1}) && ~strcmp(varargin{1},'file') 
   feval(varargin{:});
else
  import_wizard('type','EBSD');
  if check_option(varargin,'file')
    [path,fn,ext] = fileparts(get_option(varargin,'file'));
    addfile({[fn,ext]}, [path,filesep]);
  end
end


%% ------------ add data files callback -----------------------------------
function addData() %#ok<DEFNU>
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

addfile(fn,pathname);

%%
% -------------- add a files to the list ------------------------------
function addfile(fn,pathname)
global handles
global appdata

if ~isempty(appdata.interface)
  interf = {'interface',appdata.interface};
else
  interf = {};
end

handles_proceed = [handles.next handles.prev handles.finish handles.plot];
set(handles_proceed,'Visible','off');
drawnow; pause(0.001);
try
  sb = statusbar(handles.wzrd,' Importing EBSD Data ...');
  set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',length(fn), 'Value',0, 'StringPainted','on')
catch
end
  
% generate pole figure object
for i=1:length(fn)
  try
    [nebsd,appdata.interface,appdata.options] = ...
      loadEBSD(strcat(pathname,fn(i)),interf{:},appdata.options{:});
  catch
    errordlg(errortext);
    break;
  end
  
 % 
  if get(0,'CurrentFigure') == handles.wzrd
    pause(0.025); % wait that generic wizard closes
    try, set(sb.ProgressBar,'Value',i);catch end
  end
  
  %pole figures
  if ~isempty(nebsd);
    appdata.data =  [appdata.data,nebsd];
    appdata.workpath = pathname;
    appdata.filename = [appdata.filename, strcat(pathname,fn(i))];
    
    set(handles.listbox, 'String', path2filename(appdata.filename));
    set(handles.listbox,'Value',1);
    drawnow; pause(0.001);
  end
end
try, statusbar(handles.wzrd);catch,end; 

set(handles_proceed,'Visible','on');
drawnow; pause(0.001);

% set list of filenames


%% ------------ remove data callback --------------------------------------
function delData() %#ok<DEFNU>
global handles
global appdata

if ~isempty(appdata.data)
  index_selected = get(handles.listbox,'Value');
  appdata.data(index_selected) = [];
    
  if iscellstr(appdata.filename)
    appdata.filename(:,index_selected(:))=[];
  else
    appdata.filename = [];
  end;
  
  set(handles.listbox,'String', path2filename(appdata.filename));
  selected = min([index_selected,length(appdata.filename)]);
  set(handles.listbox,'Value',selected);
  
  if isempty(appdata.data)
    appdata.interface = '';
    appdata.options = {};
  end 
end


%% ------------ switch between pages --------------------------------------
function leave_page() %#ok<DEFNU>
global handles;
global appdata;

switch appdata.page  
  case 1
    if isempty(appdata.data), error('Add some data files to be imported!');end
  case 2
    appdata.data = set_cs(appdata.data, handles);
  case 3
    appdata.data = set_ss(appdata.data, handles);
end
%--------------------------------------------------------------------------
function goto_page() %#ok<DEFNU>
global handles;
global appdata;

switch appdata.page
  case 2
    handles = get_cs(appdata.data, handles);
  case 3
    handles = get_ss(appdata.data, handles);
  case 4
    str = char(appdata.data);
    set(handles.preview,'String',str);
end


%% ------------ on symmetry page ------------------------------------------
function update_cs() %#ok<DEFNU>
global handles
global appdata

appdata.data = set_cs(appdata.data, handles);
handles = get_cs(appdata.data, handles);
   

%% ---------- plotting callback -------------------------------------------
function plot_EBSD() %#ok<DEFNU>
global appdata
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 scrsz(4)/8 6*scrsz(3)/8 6*scrsz(4)/8]);

plot(appdata.data);


%% ---------- in the end ---------------------------------------------------
function finish() %#ok<DEFNU>
global handles
global appdata

if ~get(handles.runmfile,'Value');
  a = inputdlg({'enter name of workspace variable'},'MTEX Import Wizard',1,{'pf'});
  assignin('base',a{1},appdata.data);
else
  str = exportEBSD(appdata.workpath, appdata.filename, ...
    appdata.data,appdata.interface,appdata.options);
  str = generateCodeString(str);
  openuntitled(str);
end

close

