function appdata = set_hkil( appdata, handles )
% set hkli in pole figure object

ip =  get(handles.listbox_miller,'Value');

h = str2num(get(handles.miller{1}, 'String')); %#ok<ST2NM>
k = str2num(get(handles.miller{2}, 'String')); %#ok<ST2NM>
l = str2num(get(handles.miller{4}, 'String')); %#ok<ST2NM>
c = str2num(get(handles.structur, 'String')); %#ok<ST2NM>

mtex_assert(all([length(h),length(k),length(l)] == length(c)));

appdata.data(ip) = set(appdata.data(ip),'h',Miller(h,k,l,getCS(appdata.data)));
appdata.data(ip) = set(appdata.data(ip),'c',c);

get_hkil(appdata, handles);
  
