%% Configuration
%
%%
% An <GeneralConceptsOptions.html option> changes one command. A preference
% changes the default for the whole session, and the file that sets them all
% is |mtex_settings.m|:
%
%   edit mtex_settings
%
% It runs at startup, so anything changed there applies to every session
% from then on. What it sets includes
%
% * the font size, figure size and marker size of every plot
% * whether an EBSD map shows a micron bar, coordinates or a reference frame
%   indicator
% * the annotations drawn on spherical plots
% * the default colormap, and the colour palette phases are coloured from
% * the Euler angle convention, Bunge by default
% * which file extensions are offered for EBSD and pole figure files, and
%   where the import wizard starts looking
% * the paths to the bundled CIF files, data sets and examples
% * whether an imported map is <EBSDGrid.html gridified> on import
% * whether a symmetry mismatch stops with an error or only warns
% * which of the optional third party solvers are used
%
% and a good deal more. A single preference is read and written from the
% command line:
%
%   getMTEXpref('FontSize')
%   setMTEXpref('FontSize',14)
%
% and with no argument, |getMTEXpref| lists all of them with their current
% values:

getMTEXpref

%%
% Two of these are worth a word of warning.
%
% |setMTEXpref| changes the running session only. To make a change permanent
% it has to go into |mtex_settings.m|, which also means that a script
% relying on a changed preference will behave differently on somebody else's
% machine - so a published script should set what it needs explicitly rather
% than assume a configuration.
%
% And the alignment of the plots is no longer a preference at all. It
% belongs to the <referenceFrame.referenceFrame.html reference frame> the
% data lives in, which is what
% <AxesAlignment.html On Screen Coordinate System Alignment> is about.
