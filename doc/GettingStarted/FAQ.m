%% FAQ
% Frequently asked questions
%
%% Which MATLAB version and which toolboxes are reguired?
%
% MTEX requires MATLAB version 7.1 or higher and no toolboxes. It should
% also work fine on student versions.
%
%% I have crazy characters in my plots. What can I do?
%
% This indicates that your MATLAB installation has problems to interprete
% LaTex. As a workaround switch off LaTex by uncommenting the following line in
% [[matlab:edit mtex_settings.m,mtex_settings.m]].

setMTEXpref('LaTex',false);

%% I get crazy plots, empty plots, plot with wrong colors
%
% This is most likely a Matlab rendering issue. You can change the renderer
% Matlab uses for plotting by

set(gcf,'renderer','zBuffer')
