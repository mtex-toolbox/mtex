%% 3D Orientation Visualizations
%
%% Euler Angle Space
%
% By default the function <orientation.plot.html plot>
% plots orientations in the three dimensional Bunge Euler angle space

% consider cubic symmetry
cs = crystalSymmetry('cubic');

% generate 100 random orientations
ori = orientation.rand(100,cs);

% plot them
plot(ori)

%%
% Note that the orientations are automatically projected into the
% fundamental region. In the case of cubic symmetry this means that the
% Euler angles $\Phi$ and $\phi_2$ are restricted to 90 degrees. If the
% orientations should be plotted at their specified Euler angles the option
% |'ignoreFundamentalRegion'| has to be used.

plot(ori,'ignoreFundamentalRegion')

%% Axis Angle Space
%
% Alternatively, orientations can be plotted in the three dimensional axis
% angle space.

plot(ori,'AxisAngle','markerEdgeColor',[0 0 0.8],'markerSize',8,'linewidth',2)

%%
% The orientations are automatically projected into its fundamental region.
% Again, this can be switched off with the option
% |'ignoreFundamentalRegion'|.

plot(ori,'axisAngle','ignoreFundamentalRegion','markerEdgeColor',[0 0 0.8],'markerSize',8,'linewidth',2) 

% visualize the fundamental region
hold on
oR = fundamentalRegion(ori.CS,ori.SS)
plot(oR,'color',[1 0.5 0.5]),
hold off
