function appdata = set_hkil( appdata, handles )

ip =  get(handles.listbox_miller,'Value');

h = str2num(get(handles.miller{1}, 'String')); %#ok<ST2NM>
k = str2num(get(handles.miller{2}, 'String')); %#ok<ST2NM>
l = str2num(get(handles.miller{4}, 'String')); %#ok<ST2NM>
c = str2num(get(handles.structur, 'String')); %#ok<ST2NM>

assert(all([length(h),length(k),length(l)] == length(c)));

appdata.pf(ip) = set(appdata.pf(ip),'h',Miller(h,k,l,getCS(appdata.pf)));
appdata.pf(ip) = set(appdata.pf(ip),'c',c);

get_hkil(appdata, handles);
  
