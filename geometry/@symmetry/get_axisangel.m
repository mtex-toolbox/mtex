function [ c, w ] = get_axisangel( cs )

% set axes
a = getaxes(cs);
c = norm(a);
a = a./c;

w{1} = round(acos(dot(a(1),a(3)))/ degree);
w{2} = round(acos(dot(a(2),a(3)))/ degree);
w{3} = round(acos(dot(a(1),a(2)))/ degree);