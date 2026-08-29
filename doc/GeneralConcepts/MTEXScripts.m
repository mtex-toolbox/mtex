%% MTEX Scripts
%
% MTEX has no graphical user interface. You work with MTEX by writing MATLAB
% scripts: text files that keep the commands for an analysis in a reproducible
% order.
%
% A typical script follows five steps.
%
% # Import data.
% # Inspect the imported data.
% # Correct the data when necessary.
% # Analyze the data.
% # Plot and export the results.
%
% During these steps, MATLAB stores data under names called variables. Each
% variable has a type, called its class, which determines the operations that
% can be applied to it. MTEX provides classes for objects such as
% <vector3d.vector3d.html vectors>, <rotation.rotation.html rotations>,
% <EBSD.EBSD.html EBSD data>, <grain2d.grain2d.html grains>, and
% <SO3Fun.SO3Fun.html orientation distribution functions (ODFs)>. The
% <FunctionReference.html Function Reference> lists all MTEX classes and
% functions.

%% Import and inspect data
%
% Import functions create variables automatically. Here, |fileName| stores the
% path to an example CTF file. The second command imports that file and stores
% the result in the variable |ebsd|.

fileName = [mtexEBSDPath filesep 'Forsterite.ctf'];
ebsd = EBSD.load(fileName,'EulerCorrection', ...
  rotation.byAxisAngle(xvector,180*degree))

%%
% Leaving off the semicolon displays a summary of |ebsd| in the Command Window.
% This is a quick inspection step: the summary reports the phases, numbers of
% orientations, properties, map extent, and grid size. The
% |'EulerCorrection'| option also corrects the imported orientations by the
% specified rotation.

%% Plot the phase map
%
% Pass a variable to an MTEX function to operate on its data. The command below
% passes |ebsd| to |plot| and colors every indexed measurement by its phase.

plot(ebsd)

%%
% Notice the large blue forsterite regions, the smaller green enstatite and
% yellow diopside regions, and the white notIndexed areas. A notIndexed
% measurement is one whose diffraction pattern could not be indexed.

%% Reconstruct and inspect grains
%
% The next command segments the measurements into grains. A grain is a
% phase-homogeneous, spatially connected region of EBSD measurements produced
% by segmentation. The |'minPixel'| option excludes indexed grains with
% fewer than three measurements.

grains = calcGrains(ebsd,'minPixel',3)

%%
% The returned @grain2d object is stored in |grains|. Its Command Window summary
% reports the number of grains in each phase and information about their
% boundaries.

%% Add the grain boundaries
%
% Plotting on the same axes connects the result of the analysis to the phase
% map. <matlab:doc('hold') hold on> preserves the existing map while the
% boundary is added, and |hold off| ends that plotting state.

hold on
plot(grains.boundary,'lineWidth',2)
hold off

%%
% Notice that the dark lines trace changes between neighboring grains. Some
% lines lie within one color because grains of the same phase can still have
% different orientations.

%% Organize a script
%
% An MTEX script is a sequence of MATLAB and MTEX commands. Add comments on
% lines beginning with |%| to record why each command is present. These
% explanations make the analysis understandable when the script is reopened.
%
% Divide a longer script into sections with lines beginning with |%%|. In the
% MATLAB Editor, Ctrl+Enter runs the current section, while Ctrl+Shift+Enter runs
% it and advances to the next section. Running one section at a time lets you
% inspect each intermediate variable before continuing.

%% References
%
% * MathWorks, <https://www.mathworks.com/help/matlab/matlab_prog/create-scripts.html
% Create Scripts>, _MATLAB documentation_. It explains script files, comments,
% sections, and the Editor commands used on this page.

%% Next
%
% Continue with <ListsAndIndexing.html Lists and Indexing> to select parts of an
% MTEX variable and apply one operation to many stored objects.
