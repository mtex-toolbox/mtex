function set_page(handles,page)

if(page == 1) 
  set(handles.prev,'enable','off');
else
  set(handles.prev,'enable','on')
end

if(page == length(handles.tabs)) 
  set(handles.finish,'enable','on');
  set(handles.next,'enable','off');
  set(handles.plot,'visible','on');
else set(handles.finish,'enable','off');
  set(handles.plot,'visible','off')
  set(handles.next,'enable','on');
end

set(handles.tabs(1:end~=page),'visible','off');
setall(handles.tabs(page),'visible','on');
set(handles.name,'String',handles.pagename{page});


function setall(ax,varargin)

if iscell(ax), ax = cell2mat(ax);end
try
  setall(get(ax,'children'),varargin{:});
catch
end
set(ax,varargin{:});
