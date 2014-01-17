function layout = plotlayout(plots)
% determines x/y ration for good fitting on screen

scrsz = get(0,'ScreenSize');

layout(1) = round(sqrt(plots*scrsz(4)/scrsz(3)));
layout(2) = ceil(plots / layout(1));
