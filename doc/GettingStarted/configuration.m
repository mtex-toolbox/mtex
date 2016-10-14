%% Configuration
% Explains how to globally configure MTEX, i.e. how to set a default Euler angle
% convention.
%
%% Global Configuration
%
% The central place of all configuration of the MTEX toolbox is the
% m-file [[matlab:edit mtex_settings.m,mtex_settings.m]]. There the
% following items can be customized
%
% * default Euler angle convention
% * the default plotting style
% * file extension associated with EBSD and pole figure files
% * path to the CIF files
% * the default maximum iteration depth of the function [[PoleFigure.calcODF.html,calcODF]]
% * the amount of available memory
% * the path to the temporary files
% * the name of the log file
%
%
%% The Option System
%
% Many functions provided by MTEX can be customized by options. An option
% is passed to a method as a string parameter followed by a value. For
% example, almost all plotting methods support the option |RESOLUTION|
% followed by a double value specifying the resolution

odf = SantaFe
plotPDF(odf,Miller(1,0,0,odf.CS),'resolution',5*degree,'contour');

%%
% Options that are not followed by a value are called flags. In the above
% example, |contour| is a flag that says the plotting routine to plot
% contour lines. Options and flags to a function are always optional and
% can be passed in any order. If conflicting options or flags are passed,
% i.e., the resolution is specified twice, the later option in the list is
% considered to be the right one.
%
