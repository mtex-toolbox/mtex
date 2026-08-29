%% Configuration
%
% An <GeneralConceptsOptions.html option> changes one command. A preference
% supplies a default for the whole MTEX session. The central file that sets
% preferences is |mtex_settings.m|.
%
% The diagram separates the three scopes. An option is local to one command,
% while |setMTEXpref| changes the current session. Editing |mtex_settings.m|
% makes that setting take effect when MTEX starts in future sessions.
%
% <<configuration-scope.svg>>

%% Inspect the current preferences
%
% Pass a preference name to |getMTEXpref| to read its current value. With no
% input, the function returns a structure containing all current preferences.
% The available fields can depend on the installation.

getMTEXpref

%% Change one preference temporarily
%
% For example, |getMTEXpref('FontSize')| reads the current default font size,
% while |setMTEXpref('FontSize',14)| would change it to 14 for this session.
% Documentation scripts should not change global figure preferences, so the
% executable example instead uses the preference for UTF-8 Command Window
% output.
%
% The sequence saves the current value, changes it, reads the changed value,
% and restores the original. Keeping the restoration in the same section makes
% the example safe to run repeatedly.

oldUTF8Output = getMTEXpref('UTF8Output');
setMTEXpref('UTF8Output',false);
getMTEXpref('UTF8Output')
setMTEXpref('UTF8Output',oldUTF8Output);

%% Make a preference persistent
%
% Use the command |edit mtex_settings| to open the settings file. MTEX runs
% this file at startup, so an active setting there applies to every later
% session. The file groups related settings and documents the accepted values.
%
% Settings in |mtex_settings.m| include:
%
% * the font size, figure size, and marker size of every plot;
% * whether an EBSD map shows a micron bar, coordinates, or a reference-frame
% indicator;
% * the annotations drawn on spherical plots;
% * the default colormap and the color palette used for phases;
% * the Euler-angle convention, which is Bunge by default;
% * which file extensions are offered for EBSD and pole figure files, and the
% initial location used by the import wizard;
% * the paths to bundled CIF files, data sets, and examples;
% * whether an imported map is <EBSDGrid.html gridified> on import;
% * whether a symmetry mismatch stops with an error or issues only a warning;
% * which optional third-party solvers MTEX uses.
%
% The file contains additional preferences beyond this summary.

%% Keep scripts reproducible
%
% |setMTEXpref| changes only the running session. A permanent change must be
% placed in |mtex_settings.m|, but then the same <MTEXScripts.html MTEX script>
% can behave differently on another computer. A script shared or published
% for others should therefore pass important settings as command options where
% possible instead of assuming a local configuration.

%% Plot alignment is not an ordinary preference
%
% The alignment of plots is no longer an ordinary preference. It belongs to
% the <referenceFrame.referenceFrame.html reference frame> in which the data is
% expressed. A reference frame identifies the coordinate system and basis of
% the data; it is distinct from the symmetry attached to that frame.
%
% The frame supplies a plotting convention that determines how its axes are
% laid out on screen. See <AxesAlignment.html On-Screen Coordinate System
% Alignment> to set that convention explicitly instead of relying on a legacy
% axis-direction preference.

%% References
%
% This page documents MTEX configuration behavior and does not rely on an
% external method reference.

%% Next
%
% Continue with <VectorDefinition.html Vectors> to create the basic geometric
% objects used for directions, axes, and positions throughout MTEX.
