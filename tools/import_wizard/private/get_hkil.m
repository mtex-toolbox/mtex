function get_hkil( appdata, handles )

ip =  get(handles.listbox_miller,'Value');

set(handles.miller{3}, 'Enable','on');

m = getMiller(appdata.data(ip));

hkil={'h','k','i','l'};
for k=1:4
  if k ~=3,  set(handles.miller{k}, 'String', int2str(get(m,hkil{k})));
  else
    if any(strcmp(Laue(getCS(appdata.data)),{'-3m','-3','6/m','6/mmm'}))
      set(handles.miller{k}, 'String', int2str(-get(m,'h') - get(m,'k')));
    else
      set(handles.miller{k}, 'String','');
      set(handles.miller{k}, 'Enable','off');
    end
  end
end
set(handles.structur, 'String', xnum2str(getc(appdata.data(ip))));
