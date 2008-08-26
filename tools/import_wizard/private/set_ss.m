function object = set_ss(object, handles)
% set specimen symmetry

ss = symmetries(get(handles.specime,'Value'));
ss = strtrim(ss{1}(1:6));
ss = symmetry(ss);
object = set(object,'SS',ss);
