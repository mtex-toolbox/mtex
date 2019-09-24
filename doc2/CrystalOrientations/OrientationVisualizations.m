%% Plotting Orientations
%
%% Open in Editor
%
%% Contents
%
%% Euler angle space
%
% By default the function <orientation.plot.html plot>
% plots orientations in the three dimensional Bunge Euler angle space

ori = orientation.rand(100,cs);
plot(ori)

%%
% Note that the orientations are automatically projected into the
% fundamental region. In the case of cubic symmetry this means that the
% Euler angles $\Phi$ and $\phi_2$ are restricted to 90 degrees. If the
% orientations should be plotted at their specified Euler angles the option
% |ignoreFundamentalRegion| has to be used.


plot(ori,'ignoreFundamentalRegion')

%% Axis angle space
%
% Alternatively, orientations can be plotted in the three dimensional axis
% angle space.

plot(ori,'AxisAngle','markerEdgeColor',[0 0 0.8],'markerSize',8)

%%
% The orientations are automatically projected into its fundamental region.
% Again, this can be switched off with the option
% |ignoreFundamentalRegion|.

plot(ori,'axisAngle','ignoreFundamentalRegion','markerEdgeColor',[0 0 0.8],'markerSize',8) 

% visualize the fundamental region
hold on
oR = fundamentalRegion(ori.CS,ori.SS)
plot(oR,'color',[1 0.5 0.5]),
hold off

%% Pole figures
% 
% One possibility to visualize orientations in a two dimensional plot is to
% fix a crystal direction h

% the fixed crystal directions (100)
h = Miller({1,0,0},ori.CS);

%%
% and to compute the corresponding specimen directions according to the
% orientations |ori| and it symmetricaly equivalent orientations
r = ori.symmetrise * h;

plot(r,'upper')

%%
% A shortcut for the above computations is the command

% a pole figure plot
plotPDF(ori,Miller({1,0,0},{1,1,1},ori.CS))

%% Inverse pole figures
%
% Conversely, we may fix a certain specimen direction

r = vector3d.X

%%
% and compute the corresponding crystal directions
h = ori \ r

plot(h.symmetrise,'fundamentalSector' )

%%
% The shortcut for plotting inverse pole figures is

plotIPDF(ori,[vector3d.X,vector3d.Z])

%% Sections of the orientations space
%
% A third possibility are two dimensional sections through the Euler angle
% space. The most popular type of such sections are the so called phi2
% sections.

% as phi2 sections
plotSection(ori,'phi2')

%%
% More information about sections through the Euler angle space can be
% found <SigmaSections.html here>

