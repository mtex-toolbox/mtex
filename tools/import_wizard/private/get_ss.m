function handles = get_ss(object, handles)
% write ss to page

% get ss
ss = get(object,'SS');

% set specimen symmetry
ssname = strmatch(Laue(ss),symmetries);
set(handles.specime,'value',ssname(1));
