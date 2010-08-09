function import_gui_3d(wzrd)
% page for setting crystall geometry


%setappdata(wzrd,'cs_count',1);

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);
ph = 270;

this_page = get_panel(w,h,ph);
handles = getappdata(wzrd,'handles');
handles.pages = [handles.pages,this_page];
setappdata(this_page,'pagename','Set Z-Layer Value');

set(this_page,'visible','off');

  
newversion = ~verLessThan('matlab','7.6');
if ~newversion,  v0 = {}; else  v0 = {'v0'}; end

cdata =  {'Z-Layer Data Source','Z-Value'};

handles.ztable = uitable(v0{:},'parent',this_page,...
  'Data',{'filename',0},...
  'Position',[10 10 w-164 ph-65],'ColumnNames',cdata,'ColumnWidth',150);
set(handles.ztable,'Visible',false)

% get(handles.ztable)

setappdata(this_page,'goto_callback',@goto_callback);
setappdata(this_page,'leave_callback',@leave_callback);
setappdata(wzrd,'handles',handles);


%% ---------------- Callbacks --------------------------------

function goto_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;
ebsd = getappdata(lb(5),'data');
setappdata(gcbf,'data',ebsd);

Z = getappdata(lb(5),'zvalues');
c1 = [get(lb(5),'String') num2cell(Z(:))];
set(handles.ztable,'data',c1);

set(handles.ztable,'Visible',true)


function leave_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;
ebsd = getappdata(lb(5),'data');
idata = getappdata(lb(5),'idata');

tdata = cell(get(handles.ztable,'Data'));
Z = [tdata{:,2}];
setappdata(lb(5),'zvalues',Z);

csz = cumsum(idata);
  
for k=1:numel(idata)-1
  ndx = csz(k)+1:csz(k+1);
	for l=1:numel(ndx)
    xy = get(ebsd(ndx(l)),'xy');
    xy(:,3) = Z(k);
    ebsd(ndx(l)) = set(ebsd(ndx(l)),'xy',xy);
  end    
end

setappdata(gcbf,'data',union(ebsd));

set(handles.ztable,'Visible',false)