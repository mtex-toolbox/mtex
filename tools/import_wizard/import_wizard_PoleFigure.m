function import_wizard_PoleFigure( varargin )
% import helper for PoleFigure data
%

if nargin>0  && ischar(varargin{1}) && ~strcmp(varargin{1},'file') 
  feval(varargin{:});
else
  import_wizard('type','PoleFigure');
  if check_option(varargin,'file')
    [path,fn,ext] = fileparts(get_option(varargin,'file'));
    addfile({[fn,ext]}, [path,filesep]);
  end
end


%% ------------ data import callback --------------------------------------
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
  [npf,appdata.interface,appdata.options,ipf] = ...
    loadPoleFigure(strcat(pathname,fn(:)),interf{:},appdata.options{:});
  
  %pole figures
  appdata.pf =  [appdata.pf,npf];
  appdata.workpath = pathname;
  appdata.filename = [appdata.filename, strcat(pathname,fn)];
  appdata.ipf = [appdata.ipf,ipf];

  if strcmp(appdata.interface,'xrdml'), xrdml_help; end
catch
  errordlg(errortext);
end

% set list of filenames
set(handles.listbox, 'String',path2filename(appdata.filename));
set(handles.listbox,'Value',1);



%% ------------ remove data ----------------------------------------------- 
function delData()
global handles
global appdata

if ~isempty(appdata.pf)
  index_selected = get(handles.listbox,'Value');
  cpf = cumsum(appdata.ipf);
  ipf = [];
  for i = 1:length(index_selected)
    ipf = [ipf,1+cpf(index_selected(i)):cpf(index_selected(i)+1)];
  end
  
  % remove pole figure
  appdata.pf(ipf) = [];
  appdata.ipf(1+index_selected) = [];
    
  if iscellstr(appdata.filename)
    appdata.filename(:,index_selected(:))=[];
  else
    appdata.filename = [];
  end;
  
  selected = min([index_selected,length(appdata.filename)]);
 	if selected < 1, selected=1;end
  set(handles.listbox, 'String',path2filename(appdata.filename));
  set(handles.listbox,'Value',selected);
   
  if isempty(appdata.pf)
    appdata.interface = '';
    appdata.options = {};
    appdata.assert_assistance= 'None';
  end
end


%% ------------ switch between page --------------------------------------
function leave_page()
global handles;
global appdata;
switch appdata.page  
  case 1
    if isempty(appdata.pf), error('Add some data files to be imported!');end  
  case 2
    appdata = crystal2pf(appdata, handles);
  case 3
    try
      appdata = set_hkil(appdata, handles);
    catch
      error('There must be the same number of hkli and structure coefficients.');
    end
  case 4
  case 5
end
%--------------------------------------------------------------------------
function goto_page()
global handles;
global appdata;
switch appdata.page   
  case 2
    handles = pf2crystal(appdata, handles);
  case 3
    handles = setup_polefigurelist(appdata, handles);
    get_hkil(appdata, handles);
  case 4
  case 5
    str = char(appdata.pf);
    set(handles.preview,'String',str);
end


%% ------------ on symmetry page ------------------------------------------
function updatecrystal()
global handles
global appdata
appdata = crystal2pf(appdata, handles);
handles = pf2crystal(appdata, handles);


%% ------------ on miller indices page ------------------------------------
function miller_update()
global appdata
global handles
get_hkil(appdata, handles);
setup_polefigurelist(appdata, handles);
%--------------------------------------------------------------------------
function update_indices()
global appdata
global handles

try
  appdata = set_hkil(appdata, handles);
catch
end
setup_polefigurelist(appdata, handles);


%% ------------ plotting preview ------------------------------------------
function plot_PoleFigure()
global appdata
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 scrsz(4)/8 6*scrsz(3)/8 6*scrsz(4)/8]);

plot( appdata.pf,'silent');
plot2all([xvector,yvector,zvector])


%% ---------- in the end --------------------------------------------------
function finish()
global handles
global appdata

if ~get(handles.runmfile,'Value');
  a = inputdlg({'Enter name of workspace variable'},'MTEX Import Wizard',1,{'pf'});
  assignin('base',a{1},appdata.pf);
  if isempty(javachk('desktop'))
    disp(['imported PoleFigure: ', a{1}]);  

    disp(['- <a href="matlab:plot(',a{1},',''silent'')">Plot PDF</a>']);
    disp(['- <a href="matlab:calcODF(',a{1},')">Calculate ODF</a>']);
    disp(' ');
  end
else
  if ~strcmp(appdata.assert_assistance,'Yes')
    str = exportPF(appdata.workpath, appdata.filename, appdata.pf, appdata.interface, appdata.options);
  else
    str = exportPF(appdata.workpath, appdata.f, appdata.pf, appdata.interface, appdata.options);
  end
  str = generateCodeString(str);
  openuntitled(str);
end

close


