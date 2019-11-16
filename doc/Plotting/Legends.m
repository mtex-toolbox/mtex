%% Legends
%
%%
% In order display a legend to your MTEX plots you need to add the option
% |DisplayName| followed by the text that you would like to be displayed in
% the legend. Objects that are plotted without this option are not
% displayed in the legend. Eventually the legend is displayd by the command
% <https://mathworks.com/help/matlab/ref/legend.html |legend|>

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
% The <https://mathworks.com/help/matlab/ref/legend.html |legend|> command
% suport a wide varity of
% <https://mathworks.com/help/matlab/ref/matlab.graphics.illustration.legend-properties.html
% porperties> to adjust the position and appearance of the legend.
