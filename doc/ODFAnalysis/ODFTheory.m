%% The Orientation Distribution Function
%
%% Definition
%
% TODO

%% 

mtexdata titanium
odf = calcODF(ebsd.orientations)

%% Pole Figures and Values at Specific Orientations
%
% Using the command <ODF.eval.html eval> any ODF can be evaluated at any
% (set of) orientation(s).

odf.eval(orientation.byEuler(0*degree,20*degree,30*degree,odf.CS))


