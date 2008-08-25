function pf2ss(pf, handles)
% write ss to page

% get ss
ss = getSS(pf);

% set specimen symmetry
ssname = strmatch(Laue(ss),symmetries);
set(handles.specime,'value',ssname(1));
