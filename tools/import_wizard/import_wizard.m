function import_wizard( varargin )
% import data from known formats
%
%% Input
%  type     - EBSD / PoleFigure
%
%% See also
% import_wizard_EBSD import_wizard_PoleFigure

global handles
global appdata

if ~check_option(varargin,'type')
  if nargin>0  && ischar(varargin{1})
  feval(varargin{:});return
  else
    typ = {'EBSD','PoleFigure'};  
    a = listdlg('PromptString','Select Mode',...
                'SelectionMode','single',...
                'ListSize',[200 50],...
                'fus',3,...
                'ffs',1,...
                'ListString',typ);
    if ~isempty(a), import_wizard('type',typ{a});end;
  end
else
  % init global variable appdata
  appdata.workpath = cd;
  appdata.filename = [];
  appdata.interface = '';
  appdata.options = {};
  appdata.pf = [];
  appdata.ipf = 0;
  appdata.ebsd = [];
  appdata.page = 1;  
  appdata.assert_assistance = 'None';  
  appdata.type = get_option(varargin,'type');
  
  for i=1:4
    appdata.f{i} = '';
    appdata.pf_merge{i} = '';
    appdata.ipf_merge{i} = '';
  end
  
  
  var = {'type', appdata.type};
  %mainframe
  handles.wzrd = import_frame(var{:});
  
  % add pages
  handles.pages = [];
  handles = import_gui_generic( handles,var{:} );
  handles = import_gui_data( handles,var{:});
  handles = import_gui_cs( handles,var{:});   
  handles = import_gui_ss( handles );
  
  if ~strcmp(appdata.type,'EBSD')
    handles = import_gui_miller( handles );
  end

  handles = import_gui_finish( handles );
  
 switch appdata.type
   %page description
   case 'EBSD'
     handles.pagename = {'(1/4) Select Data Files',...
       '(2/4) Set Crystal Geometry',...
       '(3/4) Set Specimen Geometry',...
       '(4/4) Summary'};
   case 'PoleFigure'
      handles.pagename = {'(1/4) Select Data Files',...
        '(2/5) Set Crystal Geometry',...
        '(3/5) Set Miller Indizes',...
        '(4/5) Set Specimen Geometry',...
        '(5/5) Summary'};
 end
 set_page(handles,appdata.page);
 
end


%% switch pages
function page_next()
global handles
global appdata
if (length(handles.pages)>appdata.page)
  try
    f = str2func(['import_wizard_' appdata.type]);
    feval(f,'leave_page');
    appdata.page = appdata.page +1;
    feval(f,'goto_page');
    set_page(handles,appdata.page);
  catch
    errordlg(errortext);
  end
end

function page_prev()
global handles
global appdata
if (appdata.page>1)
  try
    f = str2func(['import_wizard_' appdata.type]);
    feval(f,'leave_page');
    appdata.page = appdata.page -1;
    feval(f,'goto_page');
    set_page(handles,appdata.page);
  catch
    errordlg(errortext);
  end
end
