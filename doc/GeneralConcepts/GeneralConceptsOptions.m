%% Options
%
%%
%
% Many functions provided by MTEX can be customized by options. An option
% is passed to a method as a string parameter followed by a value. For
% example, almost all plotting methods support the option *resolution*
% followed by a double value specifying the resolution in radiant

odf = SantaFe
plotPDF(odf,Miller(1,0,0,odf.CS),'resolution',10*degree,'contour','linewidth',2);

%%

plotPDF(odf,Miller(1,0,0,odf.CS),'resolution',2.5*degree,'contour','linewidth',2);


%%
% Options that are not followed by a value are called flags. In the above
% example, *contour* is a flag that tells the plotting routine to plot
% contour lines. Options and flags to a function are always optional and
% can be passed in any order. If conflicting options or flags are passed,
% i.e., the resolution is specified twice, the later option in the list is
% considered to be the right one.
%
 
