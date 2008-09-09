function delfile(list_handle)
% remove file from list

data = getappdata(list_handle,'data');
idata = getappdata(list_handle,'idata');
filename = getappdata(list_handle,'filename');

if ~isempty(data)
  index_selected = get(list_handle,'Value');
  cdata = cumsum(idata);
  didata = [];
  for i = 1:length(index_selected)
    didata = [didata,1+cdata(index_selected(i)):cdata(index_selected(i)+1)];
  end
  
  % remove pole figure
  data(didata) = [];
  idata(1+index_selected) = [];
    
  if iscellstr(filename)
    filename(:,index_selected(:))=[];
  else
    filename = [];
  end;
  
  selected = min([index_selected,length(filename)]);
 	if selected < 1, selected=1;end
  set(list_handle,'String',path2filename(filename));
  set(list_handle,'Value',selected);
   
  if isempty(data)
    setappdata(list_handle,'interface','');
    setappdata(list_handle,'options',{});
    setappdata(gcbf,'assert_assistance','None');
  end
  
  setappdata(list_handle,'data',data);
  setappdata(list_handle,'idata',idata);
  setappdata(list_handle,'filename',filename);

end
