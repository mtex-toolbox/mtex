function handles = setup_polefigurelist( appdata, handles )

% fill list of pole figures
for i=1:length(appdata.data) 
 m{i} = char(getMiller(appdata.data(i)));  
 p{i} = ['  ',getcomment(appdata.data(i))];
end
pflist = cellstr([strvcat(m),strvcat(p)]);

set(handles.listbox_miller, 'String', pflist);
n = get(handles.listbox_miller, 'Value');
if n <= 0 || n > length(appdata.data)
  set(handles.listbox_miller, 'Value', 1);
end
