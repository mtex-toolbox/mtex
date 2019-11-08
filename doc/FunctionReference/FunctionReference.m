%% Function Reference
%
%%
% Unlike most other texture analysis software MTEX does not have any graphical
% user interface. Instead the user is suposed to write scripts. Those scripts
% usually have the following structure
%
% # import data
% # inspect the data
% # correct the data
% # analyze the data
% # plot and export the results of the analysis
%
% During all these steps the data are stored as variables of different
% type. There are many different types of variables (called classes) for
% different objects, like <vector3d.vector3d.html vectors>,
% <rotation.rotation.html rotations>, <EBSD.EBSD.html EBSD data>,
% <grain2d.grain2d.html grains> or <ODF.ODF.html ODFs>. The sidebar on the
% left lets you browse through all different MTEX class and the
% corresponding functions.
%
% Variables are generated automatically when data are imported. E.g., the
% commands

fileName = [mtexEBSDPath filesep 'Forsterite.ctf'];
ebsd = EBSD.load(fileName)

%%
% imports data from the file |fileName.ctf| and stores them in the variable
% |ebsd| of type <https://mtex-toolbox.github.io/EBSD.EBSD.html |EBSD|>.
%
% Next one can pass the variable |ebsd| to diferent MTEX function. E.g. to
% plot a phase plot one simply does 

plot(ebsd)

%%
% The grain structure is reconstructed by the command 

grains = calcGrains(ebsd)

%%
% which returns a new variable of type <grain2d.grain2d.html |grain2d|>,
% here called |grains|. This variable contains the entire grain structure.
% Finally, we my visualize this structure by

hold on
plot(grains.boundary,'linewidth',2)
hold off
