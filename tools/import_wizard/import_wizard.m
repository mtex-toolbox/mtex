function import_wizard( type, varargin )
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


if nargin == 0,
  type = 'PoleFigure';
elseif nargin > 0
  assert( any(strcmpi(type,{'PoleFigure','EBSD','ODF'})),...
    'Specifiy data file-type first: PoleFigure, EBSD or ODF')
end

% mainframe
h = import_gui_empty('width',500,varargin{:});
iconMTEX(h);

% add pages
import_gui_generic(h);
import_gui_data(h,type);

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
import_gui_kernel(h);
import_gui_3d(h);
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

handles.pf_pages = handles.pages([1:3 7]);
handles.ebsd_pages = handles.pages([1 6 2 3 7]);
handles.odf_pages = handles.pages([1:3 5 7]);
setappdata(h,'handles',handles);

% activate first page
setappdata(h,'page',1);
set_page(h,1);

% load first data?
if nargin > 1
	switch lower(type)
    case 'polefigure'
      lb = 1;
    case 'ebsd'
      lb = 5;
    case 'odf'
      lb = 6;
  end
  
  for k=1:numel(varargin)
    addfile(handles.listbox(lb),type,'file',varargin{k});
  end
  
end

