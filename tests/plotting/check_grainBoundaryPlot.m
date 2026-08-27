function check_grainBoundaryPlot
% check the Patch and connected-chain grain boundary plotting paths

ebsd = mtexdata('small');
grains = calcGrains(ebsd('indexed'),'threshold',10*degree);
gB = grains.boundary;

% Thin boundaries use the compact Patch representation.  Round joins are
% required here: newer MATLAB renderers draw long miter spikes for the
% two-vertex faces used to represent individual boundary segments.
h = plot(gB,'lineWidth',2,'micronbar','off');
assert(isscalar(h) && isa(h,'matlab.graphics.primitive.Patch'))
assert(strcmp(h.LineJoin,'round'))
close all

% An explicit join style still overrides the robust default.
h = plot(gB,'lineWidth',2,'lineJoin','chamfer','micronbar','off');
assert(strcmp(h.LineJoin,'chamfer'))
close all

% Segment-wise transparency is the reason the Patch path is retained.
alpha = linspace(0,1,length(gB)).';
h = plot(gB,'lineWidth',2,'edgeAlpha',alpha,'micronbar','off');
assert(strcmp(h.EdgeAlpha,'flat'))
assert(isequal(h.FaceVertexAlphaData,alpha))
close all

% Thick boundaries and the smooth option draw connected ordered chains.
h = plot(gB,'lineWidth',4,'micronbar','off');
assert(all(isgraphics(h,'line')))
close all

h = plot(gB,'lineWidth',2,'smooth','micronbar','off');
assert(all(isgraphics(h,'line')))
close all

disp('check_grainBoundaryPlot: ok')

end
