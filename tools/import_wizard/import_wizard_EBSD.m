function import_wizard_EBSD( varargin )
% import helper for EBSD data
%

if nargin >0  && ischar(varargin{1})
   feval(varargin{:});
else
  import_wizard('type','EBSD');
end


%% ------------ add data files callback -----------------------------------
function addData()
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

% generate pole figure object
try
  [nebsd,appdata.interface,appdata.options] = ...
    loadEBSD(strcat(pathname,fn(:)),interf{:},appdata.options{:});

  % new directory?
  if ~strcmp(appdata.workpath,pathname)
    % replace ebsd data
    appdata.ebsd = nebsd;
    appdata.workpath = pathname;
    appdata.filename = fn;
  else     
    % add pole figures
    appdata.ebsd = [appdata.ebsd,nebsd];
    appdata.filename = [ appdata.filename , fn ];
  end
    
catch
  errordlg(errortext);
end

% set list of filenames
if get(0,'current') == handles.wzrd
  set(handles.listbox, 'String', appdata.filename);
  set(handles.listbox,'Value',1);
end



%% ------------ remove data callback --------------------------------------
function delData()
global handles
global appdata

if ~isempty(appdata.ebsd)
  index_selected = get(handles.listbox,'Value');
  appdata.ebsd(index_selected) = [];
    
  if iscellstr(appdata.filename)
    appdata.filename(:,index_selected(:))=[];
  else
    appdata.filename = [];
  end;
  
  selected = min([index_selected,length(appdata.filename)]);
  
  set(handles.listbox,'Value',selected);
  set(handles.listbox,'String', appdata.filename);
  
  if isempty(appdata.ebsd)
    appdata.interface = '';
    appdata.options = {};
  end 
end


%% ------------ switch between pages --------------------------------------
function leave_page()
global handles;
global appdata;

switch appdata.page  
  case 1
    if isempty(appdata.ebsd), error('Add some data files to be imported!');end
  case 2
    appdata = crystal2ebsd(appdata, handles);
end
%--------------------------------------------------------------------------
function goto_page()
global handles;
global appdata;

switch appdata.page
  case 2
    handles = ebsd2crystal(appdata, handles);
  case 3
    str = char(appdata.ebsd);
    set(handles.preview,'String',str);
end


%% ------------ on symmetry page ------------------------------------------
function updatecrystal()
global handles
global appdata

appdata = crystal2ebsd(appdata, handles);
handles = ebsd2crystal(appdata, handles);


%% ---------- plotting callback -------------------------------------------
function plot_EBSD()
global appdata
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 scrsz(4)/8 6*scrsz(3)/8 6*scrsz(4)/8]);

plot(appdata.ebsd);


%% ---------- in the end ---------------------------------------------------
function finish()
global handles
global appdata

if ~get(handles.runmfile,'Value');
  a = inputdlg({'enter name of workspace variable'},'MTEX Import Wizard',1,{'pf'});
  assignin('base',a{1},appdata.ebsd);
else
  str = exportEBSD(appdata.workpath, appdata.filename, ...
    appdata.ebsd,appdata.interface,appdata.options);
  str = generateCodeString(str);
  openuntitled(str);
end

close

