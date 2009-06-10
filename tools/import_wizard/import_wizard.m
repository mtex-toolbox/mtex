function import_wizard( varargin )
% import data from known formats
%
%% Input
%  file_name - files to be imported
%
%% Options
%  type - EBSD | PoleFigure
%
%% See also
% interfacesPoleFigure_index interfacesEBSD_index

% mainframe
h = import_gui_empty('width',500,varargin);
try
  jframe=get(h,'javaframe');
  jIcon=javax.swing.ImageIcon([mtex_path filesep 'mtex_icon.gif']);
  jframe.setFigureIcon(jIcon);
catch
end

% add pages
import_gui_generic(h);
import_gui_data(h,varargin{:});

% for help generation only
if get_mtex_option('generate_help')
  % activate first page
  setappdata(h,'page',1);
  set_page(h,1);
  return
end

% remaining pages
import_gui_cs(h);
import_gui_ss(h);
import_gui_miller(h);
import_gui_finish(h);


% init global variable appdata
handles = getappdata(h,'handles');
for i = 1:length(handles.listbox)
  setappdata(handles.listbox(i),'workpath',cd);
  setappdata(handles.listbox(i),'filename',[]);
  setappdata(handles.listbox(i),'interface','');
  setappdata(handles.listbox(i),'options',{});
  setappdata(handles.listbox(i),'data',[]);
  setappdata(handles.listbox(i),'idata',0);
end

handles.pf_pages = handles.pages;
handles.ebsd_pages = handles.pages([1:3 5]);
setappdata(h,'handles',handles);

% activate first page
setappdata(h,'page',1);
set_page(h,1);

% load first data?
if check_option(varargin,'file') || ...
    (nargin >= 1 && exist(varargin{1},'file'))
  [path,fn,ext] = fileparts(get_option(varargin,'file',varargin{1}));
  if check_option(varargin,'ebsd')
    lb = 2;
  else 
    lb = 1;
  end
  addfile(handles.listbox(lb),'file',{[fn,ext]}, [path,filesep],varargin{:});
end
