function varargout = wizard(varargin)
% import data from known formats
%
%
%
%% See also
% loadPoleFigure

%%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       'wizard', ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wizard_OpeningFcn, ...
                   'gui_OutputFcn',  @wizard_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%%

%% --- Executes just before wizard is made visible.
function wizard_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wizard (see VARARGIN)

% Choose default command line output for wizard
handles.output = hObject;
% Update handles struct
guidata(hObject, handles);
global pf
global page
global FileName
global PathName
global workpath

pf = [];
workpath = cd;
FileName = [];
PathName = [];
page =  1;
set_tab(hObject,handles);
        
set(handles.Bdatalist, 'String', FileName);
set(handles.Bdatalist,'Value',1);

set(handles.Ccrystalpopup, 'String', symmetries);
set(handles.Cspecimepopup, 'String', symmetries);

set([handles.i, handles.Di], 'Enable', 'off'); 

%% ------------ switch between pages --------------------------------------
%--------------------------------------------------------------------------

function leavepage(page,handles)
global pf;

switch page  
  case 1
    if isempty(pf), error('Add some data files to be imported!');end
  case 2
    crystal2pf(handles);
  case 3
    try
      set_hkli(handles);
    catch
      error('There must be the same number of hkli and structure coefficients.');
    end
  case 4

end

function gotopage(page,handles)
global pf

switch page
  case 2
    pf2crystal(handles);
  case 3
    setup_polefigurelist(handles);
    get_hkli(handles);
  case 4
    str = char(pf);
    set(handles.preview,'String',str);
end

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
global page

try
  leavepage(page,handles);
  if page < 4, page = page + 1;end
  gotopage(page,handles);
  set_tab(hObject,handles);
catch
  errordlg(errortext);
end

% --- Executes on button press in prev.
function prev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
global page

try
  leavepage(page,handles);
  if page > 1, page = page - 1;end
  gotopage(page,handles);
  set_tab(hObject,handles);
catch
  errordlg(errortext);
end

%% ------------- First Page -----------------------------------------------
% -------------------------------------------------------------------------

% --- Executes on button press in Badd.
function Badd_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
global pf
global FileName
global PathName
global workpath

[fn,PathName] = uigetfile( mtexfilefilter,...
  'Select Data files',...
  'MultiSelect', 'on',...
  workpath );
                                     
if ~iscellstr(fn), fn = {fn};end;
                                     
if PathName ~= 0
  
  % generate pole figure object
  try
    npf = loadPoleFigure(strcat(PathName,fn(:)));
        
    % new directory?
    if ~strcmp(workpath,PathName) 
      
      % replace pole figures
      pf = npf;
      workpath = PathName;
      FileName = fn;                
    else
      
      % add pole figures
      pf = [pf,npf];
      FileName = [ FileName , fn ];
    end
    
  catch
    errordlg(errortext);
  end
  
  % set list of filenames
  set(handles.Bdatalist, 'String', FileName);
  set(handles.Bdatalist,'Value',1);
  
end

% --- Executes on button press in Bremove.
function Bremove_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
global FileName
global pf;

if ~isempty(pf)
  
  index_selected = get(handles.Bdatalist,'Value');
  
  % remove pole figure
  pf(index_selected) = [];
    
  if iscellstr(FileName)
    FileName(:,index_selected(:))=[];
  else
    FileName = [];
  end;
  
  selected = min([index_selected,length(FileName)]);
  
  set(handles.Bdatalist,'Value',selected);
  set(handles.Bdatalist,'String', FileName);
  
end


%% ----------------- Second page ------------------------------------------
%--------------------------------------------------------------------------

% load symmetries from global pf object
function pf2crystal(handles)
global pf;

% set crystal symmetry
cs = getCS(pf);
csname = strmatch(Laue(cs),symmetries);
set(handles.Ccrystalpopup,'value',csname(1));

% set axes
a = getaxes(cs);
c = norm(a);
a = a./c;

set(handles.Ca,'String',c(1));
set(handles.Cb,'String',c(2));
set(handles.Cc,'String',c(3));

% set angle
alpha = round(acos(dot(a(1),a(3)))/ degree);
beta = round(acos(dot(a(2),a(3)))/ degree);
gamma = round(acos(dot(a(1),a(2)))/ degree);

set(handles.Calpha,'String',alpha); 
set(handles.Cbeta,'String',beta); 
set(handles.Cgamma,'String',gamma);

% set specimen symmetry
ssname = strmatch(Laue(getSS(pf)),symmetries);
set(handles.Cspecimepopup,'value',ssname(1));

% deactivate unused fields
axes_length = [ handles.Ca, handles.Cb, handles.Cc];
axes_angle = [ handles.Calpha, handles.Cbeta, handles.Cgamma ];

set([axes_length axes_angle], 'Enable', 'on');

if ~strcmp(Laue(getCS(pf)),{'-1','2/m'}), set(axes_angle, 'Enable', 'off');end
  
if any(strcmp(Laue(getCS(pf)),{'m-3m','m-3'})), 
  set(axes_length, 'Enable', 'off');
end


% store symmetries to global pf object
function crystal2pf(handles)
global pf

cs = get(handles.Ccrystalpopup,'Value');
cs = symmetries(cs);
cs = strtrim(cs{1}(1:6));
a = str2num(get(handles.Ca,'String')); %#ok<ST2NM>
b = str2num(get(handles.Cb,'String')); %#ok<ST2NM>
c = str2num(get(handles.Cc,'String')); %#ok<ST2NM>
alpha = str2num(get(handles.Calpha,'String'))*degree; %#ok<ST2NM>
beta = str2num(get(handles.Cbeta,'String'))*degree; %#ok<ST2NM>
gamma = str2num(get(handles.Cgamma,'String'))*degree; %#ok<ST2NM>

cs = symmetry(cs,[a b c],[alpha,beta,gamma]);
pf = set(pf,'CS',cs);

ss = symmetries(get(handles.Cspecimepopup,'Value'));
ss = strtrim(ss{1}(1:6));
ss = symmetry(ss);
pf = set(pf,'SS',ss);

% --- Executes on selection change in Ccrystalpopup.
function Ccrystalpopup_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

crystal2pf(handles);
pf2crystal(handles);


%% -------------------------- Third Page ----------------------------------
%--------------------------------------------------------------------------

%%
function setup_polefigurelist(handles)

global pf

% fill list of pole figures
for i=1:length(pf) 
 m{i} = char(getMiller(pf(i)));  
 p{i} = ['  ',getcomment(pf(i))];
 %pflist{i} = sprintf('%s\t%s',char(getMiller(pf(i))),getcomment(pf(i)));
end
pflist = cellstr([strvcat(m),strvcat(p)]); %#ok<VCAT>

set(handles.Dpolefigurelist, 'String', pflist);
n = get(handles.Dpolefigurelist, 'Value');
if n <= 0 || n > length(pf)
  set(handles.Dpolefigurelist, 'Value', 1);
end

% store hkl to global pf object
function set_hkli(handles)
global pf

ip =  get(handles.Dpolefigurelist,'Value');

h = str2num(get(handles.Dh, 'String')); %#ok<ST2NM>
k = str2num( get(handles.Dk, 'String')); %#ok<ST2NM>
l = str2num(get(handles.Dl, 'String')); %#ok<ST2NM>
c = str2num(get(handles.Dscale, 'String')); %#ok<ST2NM>
assert(length(h) == length(c));

pf(ip) = set(pf(ip),'h',Miller(h,k,l,getCS(pf)));
pf(ip) = set(pf(ip),'c',c);
get_hkli(handles);


% retrieve hkl from global pf object
function get_hkli(handles)
global pf

ip =  get(handles.Dpolefigurelist,'Value');

m = getMiller(pf(ip));

set(handles.Dh, 'String', int2str(get(m,'h')));
set(handles.Dk, 'String', int2str(get(m,'k')));
set(handles.Dl, 'String', int2str(get(m,'l')));

if any(strcmp(Laue(getCS(pf)),{'-3m','-3','6/m','6/mmm'}))
  set(handles.Di, 'String', int2str(-get(m,'h') - get(m,'k')));
else
  set(handles.Di, 'String','');
end

set(handles.Dscale, 'String', n2s(getc(pf(ip))));


% --- Executes on selection change in Dpolefigurelist.
function Dpolefigurelist_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
get_hkli(handles);
setup_polefigurelist(handles);

function Dh_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
try set_hkli(handles);end %#ok<TRYNC>

function Dk_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
try set_hkli(handles);end %#ok<TRYNC>

function Di_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
try set_hkli(handles);end %#ok<TRYNC>

function Dl_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
try set_hkli(handles);end %#ok<TRYNC>

function Dscale_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
try set_hkli(handles);end %#ok<TRYNC>


%% --------------------------- Fourth Page --------------------------------
% -------------------------------------------------------------------------

% plot pole figures
function plot_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
global pf

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 scrsz(4)/8 6*scrsz(3)/8 6*scrsz(4)/8]);
plot(pf);


% 
function str = generateCodeString(strCells)
str = [];
for n = 1:length(strCells)
    str = [str, strCells{n}, sprintf('\n')];
end

% --- Executes on button press in finish.
function finish_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
global pf
global FileName
global PathName

if ~get(handles.runmfile,'Value');
  a = inputdlg({'enter name of workspace variable'},'MTEX Import Wizard',1,{'pf'});
  assignin('base',a{1},pf);
else
  str = exportPF(PathName, FileName, pf);
  str = generateCodeString(str);
  % Throw to command window if java is not available
  err = javachk('mwt','The MATLAB Editor');
  if ~isempty(err)
    local_display_mcode(str,'cmdwindow');
  end
  com.mathworks.mlservices.MLEditorServices.newDocument(str,true);
end

close(handles.wizard);


%% set visible objects depending on tab page
function set_tab(hObject,handles) %#ok<INUSL,DEFNU>
global page
handles.tabA = [ handles.plot,handles.preview, handles.runmfile ];
handles.tabB = [ handles.Bdatalist, handles.Badd, handles.Bremove];
                  
handles.tabC = [ handles.Cspecimepopup, handles.Ccrystalpopup, ...
                 handles.specime, handles.crystal, ...
                 handles.Ca, handles.Cb, handles.Cc, ... 
                 handles.a, handles.b, handles.c, ...
                 handles.alpha, handles.beta, handles.gamma, ...
                 handles.Calpha, handles.Cbeta, handles.Cgamma, ...
                 handles.axis, handles.angles ];
handles.tabD = [ handles.Dpolefigurelist, ...
                handles.h, handles.k, handles.i, handles.l, ...
                handles.Dh, handles.Dk, handles.Di, handles.Dl, ...
                handles.scoeff,handles.scale, handles.Dscale,...
                handles.Miller ];
            
handles.all =  [ handles.tabA,handles.tabB,handles.tabC,handles.tabD ];
set(handles.all, 'Visible', 'off');

set(handles.prev, 'Enable', 'on');
set(handles.next, 'Enable', 'on');
set(handles.finish, 'Enable','off');

switch page 
    case 1
        set(handles.tabB, 'Visible', 'on');
        set(handles.prev, 'Enable', 'off');
        set(handles.subtitle, 'String', '( 1 / 4 ) Select Diffraction Data');
    case 2
        set(handles.tabC, 'Visible', 'on');
        set(handles.subtitle, 'String', '( 2 / 4 ) Set Symmetries');
    case 3
        set(handles.tabD, 'Visible', 'on');
        set(handles.subtitle, 'String', '( 3 / 4 ) Set Miller Indices');
   
    case 4  
        set(handles.tabA, 'Visible', 'on');
        set(handles.subtitle, 'String', '( 4 / 4 ) Summary');
        set(handles.next, 'Enable', 'off');
        set(handles.finish, 'Enable','on');
end


%% Some Dummy functions
% --- Executes on selection change in Cspecimepopup.
function Cspecimepopup_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Ca_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Cb_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Cc_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Calpha_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Cbeta_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Cgamma_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function Bdatalist_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function runmfile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function preview_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

%%
% --- Executes during object creation, after setting all properties.
function Cspecimepopup_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Ca_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Cb_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Cc_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Calpha_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Cbeta_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Cgamma_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Cd_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Dpolefigurelist_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Dh_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Dk_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Di_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Dl_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Ccrystalpopup_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Dscale_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Bdatalist_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function preview_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function varargout = wizard_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL,INUSL>
varargout{1} = handles.output;

function s = errortext
e = lasterror;
e = e.message;
pos = strfind(e,'</a>');
s = e(pos+5:end);

function s = n2s(n)

s = num2str(n);
s = regexprep(s,'\s*','  ');
