%% FAQ
% Frequently asked questions
%
%
%% Why is there no graphical user interface?
%
% In contrast to almost any other texture analysis software MTEX has no
% graphical user interface but provides scripting languages. We believe
% that this has the following advantages
%
% * documented workflow: you will always remember all options which gave you the result
% * reproducible results: running a script multiple times gives you the same results
% * templates for common tasks: just replace the names of the data files and repeat the calculations
% * automatically process multiple data sets with different parameters
% * great flexibility: you can combine every tool with every other tool
%
% On the downside, scripts are often thought to be complicated to learn and
% tedious to write. However, how would you learn a GUI bases program? You
% would use a script which tells you in which order to click which buttons.
% In MTEX you give the script directly to the computer and he does process
% it for you. We also believe that MTEX scripts are easy to read for humans
% as well. Take the following example:

% import some EBSD data, while aligning the x,y coordinates to follow the
% Euler angle coordinate system
ebsd = loadEBSD([mtexDataPath filesep 'EBSD' filesep 'twins.ctf'],'convertSpatial2EulerReferenceFrame' );

% plot the orientations
plot(ebsd('indexed'),ebsd('indexed').orientations)

% compute grains
grains = calcGrains(ebsd('indexed'));

% and draw the grain boundaries
hold on
plot(grains.boundary)
hold off

%% Why Matlab? 
%
% Matlab offers a very comfortable scripting interface as well as a very
% powerful graphics engine. A reasonable alternative is Phyton which
% would have several advantages. However, so far there are no plans for
% migration.
%
%% Which Matlab version and which toolboxes do I need?
%
% MTEX does not require any additional Matlab toolbox and shall work fine
% with student version. A comprehensive table that shows which MTEX version
% runs on which Matlab versions can be found <installation.html here>.
%
%% I get crazy plots, empty plots, plot with wrong colors
%
% This is most likely a Matlab rendering issue. You can change the renderer
% Matlab uses for plotting by

% this is some arbitrary plot command
plot(grains('indexed'),grains('indexed').meanOrientation)

% apply this command directly after the plot command
set(gcf,'renderer','zBuffer')

%% I have crazy characters in my plots. What can I do?
%
% This indicates that your MATLAB installation has problems to interpret
% LaTex. As a workaround switch off LaTex by uncommenting the following
% line in <matlab:edit('mtex_settings.m') mtex_settings.m>.

setMTEXpref('LaTex',false);

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

%% MTEX fails to import EBSD OSC files
%
% The OSC file format is a commercial binary EBSD format that has undergone
% heavy changes. For that reason it is hard for MTEX to keep up with a
% functional interface. As a workaround export your data to ANG file. Those
% can be easily imported into MTEX.

%% 