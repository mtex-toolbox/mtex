%% MTEX CONFIGURATION
%
%% Global Configuration
%
% The central place of all configuration of the MTEX toolbox is the
% m-file [[matlab:edit ../../startup_mtex,startup_mtex]]. There the
% following items can be customized
%
% * the default maximum iteration depth of the function [[PoleFigure_calcODF.html,calcODF]]
% * the path to the temporary files
% * the name of the log file
% * commands to be executed befor and after an extern program call
%
%
%% Local Configuration
%
% Many functions provided by MTEX can be customized by options. A option
% is passed to a method as a string parameter followed by a value. For
% example allmost all ploting methods support the option |RESOLUTION|
% followed by a double value specifying the resolution

plotpdf(odf,'resolution',5*degree,'contour');

%%
% Options that are not followed by a value are called flag. In the above
% example |contour| is a flag that says the plotting routine to plot
% contour lines. Options and flags to a function are allways optional and
% can be passed in any order.
%
