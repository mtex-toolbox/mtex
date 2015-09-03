%% FAQ
% Frequently asked questions
%
%% Which MATLAB version and which toolboxes are reguired?
%
% MTEX has been succesfully tested on MATLAB version 2012b with no
% toolboxes. It should also work fine on student versions.
%
%% I have crazy characters in my plots. What can I do?
%
% This indicates that your MATLAB installation has problems to interprete
% LaTex. As a workaround switch off LaTex by uncommenting the following
% line in [[matlab:edit mtex_settings.m,mtex_settings.m]].

setMTEXpref('LaTex',false);

%% I get crazy plots, empty plots, plot with wrong colors
%
% This is most likely a Matlab rendering issue. You can change the renderer
% Matlab uses for plotting by

set(gcf,'renderer','zBuffer')

%% How can I import my data
%
% You might use the import_wizard by typing

import_wizard

%%
% See also
%
% * <http://mtex-toolbox.github.io/files/doc/ImportPoleFigureData.html
% import pole figure data>
% * <http://mtex-toolbox.github.io/files/doc/ImportPoleFigureData.html
% import ODFs>
% * <http://mtex-toolbox.github.io/files/doc/ImportEBSDData.html
% import EBSD data>
% * <http://mtex-toolbox.github.io/files/doc/ImportEBSDData.html
% import individual orientations>
% * <http://mtex-toolbox.github.io/files/doc/ImportEBSDData.html
% import tensors>

%% I can not import EBSD OSC files 
%
% The OSC file format is a commercial binary EBSD format that has undergone
% heavy changes. For that reason it hard for MTEX to keep up with a
% functional interface. As a workaround export your data to ANG file. Those
% can be easily imported into MTEX.

