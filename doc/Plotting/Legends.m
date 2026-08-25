%% Legends
%
%%
% A legend is opt in: MTEX puts an entry in it for everything that was
% plotted with a |DisplayName|, and leaves out everything else. That is the
% opposite of MATLAB's default and it is deliberate - a figure that
% superposes markers, circles and a colour coded background would otherwise
% produce a legend nobody can read.

% this is a point
plot(vector3d.X,'upper','DisplayName','a point')
hold on

% this is a fibre
circle(vector3d.X,'DisplayName','a fibre','lineColor','r','linewidth',2)

% this will not show up in the legend
plot(vector3d.Z,'Marker','p','MarkerSize',30)
hold off

% display legend
legend

%%
% Two of the three things in this figure are named, so the legend has two
% entries. The star at the centre was plotted without a |DisplayName| and is
% simply not mentioned.
%
% From there on it is the ordinary MATLAB
% <https://mathworks.com/help/matlab/ref/legend.html |legend|> command, with
% its
% <https://mathworks.com/help/matlab/ref/matlab.graphics.illustration.legend-properties.html
% properties> for placing and styling the box.
