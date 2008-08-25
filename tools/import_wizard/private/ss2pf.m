function pf = ss2pf(pf, handles)
% set specimen symmetry

ss = symmetries(get(handles.specime,'Value'));
ss = strtrim(ss{1}(1:6));
ss = symmetry(ss);
pf = set(pf,'SS',ss);
