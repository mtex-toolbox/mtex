% Calculalating and plotting elastic velocities (km/s) from elasticity stiffness
% Cijkl tensor (GPa) and density (g/cm3)
%
% By David Mainprice
%
disp(' ')
disp(' Seismics_Single_Crystal_Olivine_Multiplot.m by David Mainprice')
disp(' Last revised 18/01/2013 Demo for MTEX 3.4 beta1')
disp(' FUNCTION:')
disp(' Calculating and plotting elastic velocities (km/s) from')
disp(' from elasticity stiffness Cijkl tensor (GPa) and density (g/cm3')
disp(' using the open source Texture analysis toolbox MTEX')
disp(' ')
disp(' further information about this script e-mail: David.Mainprice@gm.univ-montp2.fr')
disp(' ')
disp(' for further information about MTEX see http://code.google.com/p/mtex/')
disp(' ')
%
%%
%**************************************************************************
% Specify Crystal Symmetry (cs)
%**************************************************************************
%
% crystal symmetry - Orthorhombic mmm
% Olivine structure 
% (4.7646 10.2296 5.9942 90.00 90.00 90.00) - Orthorhombic
cs_tensor = symmetry('mmm',[4.7646,10.2296,5.9942],...
    [90.00,90.00,90.00]*degree,'x||a','z||c','mineral','Olivine');
%
%**************************************************************************
% Import 4th rank tensor as 6 by 6 matrix
%**************************************************************************
%
% Olivine elastic stiffness (Cij) Tensor in GPa
% Abramson E.H., Brown J.M., Slutsky L.J., and Zaug J.(1997)
% The elastic constants of San Carlos olivine to 17 GPa.
% Journal of Geophysical Research 102: 12253-12263.
%
%  320.5 68.15  71.6     0     0     0
%  68.15 196.5  76.8     0     0     0
%   71.6  76.8 233.5     0     0     0
%      0     0     0    64     0     0
%      0     0     0     0    77     0
%      0     0     0     0     0  78.7
%
% Enter tensor as 6 by 6 matrix,M line by line.
%
M = [[320.5  68.15  71.6     0     0     0];...
    [ 68.15  196.5  76.8     0     0     0];...
    [  71.6   76.8 233.5     0     0     0];...
    [   0      0      0     64     0     0];...
    [   0      0      0      0    77     0];...
    [   0      0      0      0     0  78.7]];
%
%**************************************************************************
% Define tenor object in MTEX
% Cij -> Cijkl - elastic stiffness tensor
%**************************************************************************
%
C = tensor(M,cs_tensor);
%**************************************************************************
% Define density (g/cm3)
%**************************************************************************
rho=3.355;
%
%%
%**************************************************************************
% Generate velocities and polarizations on a fine pole figure S2Grid
XY_grid=equispacedS2Grid('HEMISPHERE','upper', 'resolution',1*degree);
[vp,vs1,vs2,pp,ps1,ps2] = velocity(C,XY_grid,rho);
%**************************************************************************
% P-wave velocity (km/s)
% Maximum and Minimum values and thier directions
%**************************************************************************
%
Vp_max_value = max(vp);
Vp_min_value = min(vp);
% Anisotropy percent
AVp=200*(Vp_max_value-Vp_min_value)/(Vp_max_value+Vp_min_value);
% index values on S2Grid
[~,index_max] = max(vp);
[~,index_min] = min(vp);
% vector in S2Grid
Vp_max_vector = XY_grid(index_max);
Vp_min_vector = XY_grid(index_min);
%**************************************************************************
% S-wave anisotropy percentage
% defined as AVs = 200*(Vs1-Vs2)/(Vs1+Vs2)
% Maximum and Minimum values and thier directions
%**************************************************************************
% new array AVs %
avs = 200*(vs1-vs2)./(vs1+vs2);
AVs_max_value = max(avs);
AVs_min_value = min(avs);
% index values on S2Grid
[~,index_max] = max(avs);
[~,index_min] = min(avs);
% vector in S2Grid
AVs_max_vector = XY_grid(index_max);
AVs_min_vector = XY_grid(index_min);
%**************************************************************************
% dVs = Vs1-Vs2 (km/s)
% Maximum and Minimum values and thier directions
%**************************************************************************
% new array AVs %
dVs = vs1-vs2;
dVs_max_value = max(dVs);
dVs_min_value = min(dVs);
% index values on S2Grid
[~,index_max] = max(dVs);
[~,index_min] = min(dVs);
% vector in S2Grid
dVs_max_vector = XY_grid(index_max);
dVs_min_vector = XY_grid(index_min);
%**************************************************************************
% S1-wave velocity (km/s)
% Maximum and Minimum values and thier directions
%**************************************************************************
%
Vs1_max_value = max(vs1);
Vs1_min_value = min(vs1);
% Anisotropy percent
AVs1=200*(Vs1_max_value-Vs1_min_value)/(Vs1_max_value+Vs1_min_value);
% index values on S2Grid
[~,index_max] = max(vs1);
[~,index_min] = min(vs1);
% vector in S2Grid
Vs1_max_vector = XY_grid(index_max);
Vs1_min_vector = XY_grid(index_min);
%**************************************************************************
% S2-wave velocity (km/s)
% Maximum and Minimum values and thier directions
%**************************************************************************
%
Vs2_max_value = max(vs2);
Vs2_min_value = min(vs2);
% Anisotropy percent
AVs2=200*(Vs2_max_value-Vs2_min_value)/(Vs2_max_value+Vs2_min_value);
% index values on S2Grid
[~,index_max] = max(vs2);
[~,index_min] = min(vs2);
% vector in S2Grid
Vs2_max_vector = XY_grid(index_max);
Vs2_min_vector = XY_grid(index_min);
%**************************************************************************
% Vp/Vs1 (no units)
% Maximum and Minimum values and thier directions
%**************************************************************************
% new array vpvs1
vpvs1 = vp./vs1;
VpVs1_max_value = max(vpvs1);
VpVs1_min_value = min(vpvs1);
% Anisotropy percent
AVpVs1=200*(VpVs1_max_value-VpVs1_min_value)/(VpVs1_max_value+VpVs1_min_value);
% index values on S2Grid
[~,index_max] = max(vpvs1);
[~,index_min] = min(vpvs1);
% vector in S2Grid
VpVs1_max_vector = XY_grid(index_max);
VpVs1_min_vector = XY_grid(index_min);
%**************************************************************************
% Vp/Vs2 (no units)
% Maximum and Minimum values and thier directions
%**************************************************************************
% new array vpvs2
vpvs2 = vp./vs2;
VpVs2_max_value = max(vpvs2);
VpVs2_min_value = min(vpvs2);
% Anisotropy percent
AVpVs2=200*(VpVs2_max_value-VpVs2_min_value)/(VpVs2_max_value+VpVs2_min_value);
% index values on S2Grid
[~,index_max] = max(vpvs2);
[~,index_min] = min(vpvs2);
% vector in S2Grid
VpVs2_max_vector = XY_grid(index_max);
VpVs2_min_vector = XY_grid(index_min);
%%
%**************************************************************************
% Plotting section
%**************************************************************************
% plotting convention
% set the default plot direction of the X-axis
%
plotx2north;
% close all open graphics
close all
%
% set colour map to seismic color map : blue2redColorMap
setMTEXpref('defaultColorMap',blue2redColorMap)
% color bar width and height
wcb = 0.008;
hcb = 0.215;
xfactor = 1.05;
%
%**************************************************************************
% Setup multiplot
%**************************************************************************
% define plot size [origin X,Y,Width,Height]
figure('position',[0 0 1000 1000])
%
% Standard Seismic plot with 8 subplots in 3 by 3 matrix
%
% Plot matrix layout
%        1 Vp        2 AVs      3 S1 polarizations
%        4 Vs1       5 Vs2      6 dVs
%        7 Vp/Vs1    8 Vp/Vs2
%
%**************************************************************************
% Vp : Plot P-wave velocity (km/s)
%**************************************************************************
%
% *** need density rho in plot command for velocity ***
%
% set position 1 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,1);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
%
% Plot P-wave velocity (km/s)
%
plot(axesPos,C,'density',rho,'PlotType','velocity','vp','complete','contourf')
% colorbar position [x,y,width,height],font size
%set(colorbar,'Position',[0.3 0.71 0.005 0.21],'FontSize',16)
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('Vp (km/s)','FontSize',18,'FontWeight','bold')
% percentage anisotropy
AVpS = ['Vp Anisotropy = ',num2str(AVp,'%6.1f')];
% N.B. x and y reversed in subplot
ylabel(AVpS,'FontSize',18,'FontWeight','bold') 
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(Vp_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(Vp_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
%**************************************************************************
% AVS : Plot S-wave anisotropy percentage for each proppagation direction
% defined as AVs = 200*(Vs1-Vs2)/(Vs1+Vs2)
%**************************************************************************
%
% set position 2 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,2);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
%
% Plot S-wave anisotropy (percent)
%
plot(axesPos,C,'density',rho,'PlotType','velocity','200*(vs1-vs2)./(vs1+vs2)','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('S-wave anisotropy (%)','FontSize',18,'FontWeight','bold')
% Max percentage anisotropy
AVsS = ['Max Vs Anisotropy = ',num2str(AVs_max_value,'%6.1f')];
ylabel(AVsS,'FontSize',18,'FontWeight','bold')
% mark maximum crystal axes
hold on
plot(axesPos,[xvector,yvector,zvector],'label',{'[100] ','[010] ','[001] '},'backgroundcolor','w');
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(AVs_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(AVs_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
%
%**************************************************************************
% S1 Polarization: Plot fastest S-wave (Vs1) polarization directions
%**************************************************************************
%
% set position 3 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,3);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
plot(axesPos,C,'density',rho,'PlotType','velocity','200*(vs1-vs2)./(vs1+vs2)','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('Vs1 polarization','FontSize',18,'FontWeight','bold')
hold on
plot(axesPos,C,'density',rho,'PlotType','velocity','ps1',...
'complete','linewidth',2,'color','black')
hold off
%
%
%**************************************************************************
% Vs1 : Plot Vs1 velocities (km/s)
%**************************************************************************
%
% set position 4 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,4);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
plot(axesPos,C,'density',rho,'PlotType','velocity','vs1','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('Vs1 (km/s)','FontSize',18,'FontWeight','bold')
% Percentage anisotropy
AVs1S = ['Vs1 Anisotropy = ',num2str(AVs1,'%6.1f')];
ylabel(AVs1S,'FontSize',18,'FontWeight','bold') 
hold on
plot(axesPos,C,'density',rho,'PlotType','velocity','ps1',...
'complete','linewidth',2,'color','black')
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(Vs1_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(Vs1_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
%
%**************************************************************************
% Vs2 : Plot Vs2 velocities (km/s)
%**************************************************************************
%
% set position 5 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,5);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
plot(axesPos,C,'density',rho,'PlotType','velocity','vs2','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('Vs2 (km/s)','FontSize',18,'FontWeight','bold')
% Percentage anisotropy
AVs2S = ['Vs2 Anisotropy = ',num2str(AVs2,'%6.1f')];
ylabel(AVs2S,'FontSize',18,'FontWeight','bold') 
hold on
plot(axesPos,C,'density',rho,'PlotType','velocity','ps2',...
'complete','linewidth',2,'color','black')
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(Vs2_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(Vs2_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
%
%**************************************************************************
% dVs : Plot Velocity difference Vs1-Vs2 (km/s) plus Vs1 polarizations
%**************************************************************************
%
% set position 6 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,6);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
plot(axesPos,C,'density',rho,'PlotType','velocity','vs1-vs2','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('dVs=Vs1-Vs2 (km/s)','FontSize',18,'FontWeight','bold')
% Max percentage anisotropy
AdVsS = ['Max dVs (km/s) = ',num2str(dVs_max_value,'%6.2f')];
ylabel(AdVsS,'FontSize',18,'FontWeight','bold')
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(dVs_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(dVs_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
%**************************************************************************
% Vp/Vs1 : Plot Vp/Vs1 ratio (no units)
%**************************************************************************
%
% set position 7 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,7);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
plot(axesPos,C,'density',rho,'PlotType','velocity','vp./vs1','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('Vp/Vs1','FontSize',18,'FontWeight','bold')
% Percentage anisotropy
AVpVs1S = ['Vp/Vs1 Anisotropy = ',num2str(AVpVs1,'%6.1f')];
ylabel(AVpVs1S,'FontSize',18,'FontWeight','bold')
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(VpVs1_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(VpVs1_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
% 
%
%**************************************************************************
% Vp/Vs2 : Plot Vp/Vs2 ratio (no units)
%**************************************************************************
%
% set position 8 in a 3x3 matrix as the current plotting position
axesPos = subplot(3,3,8);
% current axes position
CAP = get(gca,'Position');
% x,y position of colorbar 
xcb = CAP(1) + xfactor*CAP(3);
ycb = CAP(2);
plot(axesPos,C,'density',rho,'PlotType','velocity','vp./vs2','complete','contourf');
set(colorbar,'Position',[xcb ycb wcb hcb],'FontSize',16)
title('Vp/Vs2','FontSize',18,'FontWeight','bold')
% Percentage anisotropy
AVpVs2S = ['Vp/Vs2 Anisotropy = ',num2str(AVpVs2,'%6.1f')];
ylabel(AVpVs2S,'FontSize',18,'FontWeight','bold')
% mark maximum with black square and minimum with white circle
hold on
plot(axesPos,vector3d(VpVs2_max_vector),'Marker','s','MarkerSize',10,...
'MarkerEdgeColor','white','MarkerFaceColor','black')
plot(axesPos,vector3d(VpVs2_min_vector),'Marker','o','MarkerSize',10,...
'MarkerEdgeColor','black','MarkerFaceColor','white')
hold off
%
%
% save plot as *.pdf file
savefigure('Plot_Olivine_Single_Crystal_seismic_analysis.pdf');
%
%
% reset colour map to default for MTEX 
setMTEXpref('defaultColorMap',WhiteJetColorMap);
%
disp(' ')
disp(' Script has successfully terminated')
disp(' ')
%
% End of script
%
