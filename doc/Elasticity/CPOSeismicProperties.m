%% Plot seismic wave velocities and polarization directions
%
%  In this section we will calculate the elastic properties of an aggregate
%  and plot its seismic properties in pole figures that can be directly
%  compare to the pole figures for CPO
%
%  Let's first import an example dataset from the MTEX toolboox

mtexdata forsterite

% This dataset consist of the three main phases, olivine, enstatite and
% diopside. As we want to plot the seismic properties of this aggregate, we
% need (i) the modal proportions of each phase in this sample, (ii) their
% orientations, which is given by their ODFs, (iii) the elastic constants 
% of the minerals and (iv) their densities. One can use the modal
% proportions that appear in the command window (ol=62 %, en=11%, dio=4%), 
% but there is a lot of non-indexed data. You can recalculate the data only
% for the indexed data

%% Correct EBSD spatial coordinates
%
% This EBSD dataset has the foliation N-S, but standard CPO plots and
% physical properties in geosciences use an external reference frame where
% the foliation is vertical E-W and the lineation is also E-W but
% horizontal. We can correct the data by rotating the whole dataset like

ebsd = rotate(ebsd,rotation('axis',-zvector,'angle',90*degree))

%% Calculate the area fraction of each phase in this map

% list of phase names
Phase_names = ebsd.mineralList;
% zero area fractions
Area_Fractions = zeros(numel(Phase_names));
% number of measurement points in the map
Map_points = length(ebsd);
% default first phase is indexed the perfect sample !
N_first_indexed_phase = 1;
% remove 'nonIndexed' points from total
% if 'notIndexed' is present
if(strcmp(Phase_names(1),'notIndexed'))
    N_first_indexed_phase = 2;
end

%% Calculate the area fraction considering the non-indexed pixels

fprintf(' \n')
fprintf(' Area fractions for all phases in the EBSD object \n')
fprintf(' \n')
fprintf('   #      Phase       Points  Area fraction \n')
for i=1:numel(Phase_names);
% indexed point for mineral
N_Points = length(ebsd(Phase_names(i)));
   if(N_Points > 0)
% area fraction for mineral
Area_Fractions(i) = N_Points/Map_points;
% retain first part of mineral name
P_Name = strtok(char(Phase_names{i}),' ');
      fprintf(' %3i %12s %10i %11.4f \n',...
      i,P_Name,N_Points,Area_Fractions(i))
   end
end
AF_total = sum(sum(Area_Fractions));
fprintf(' \n')
fprintf(' Total area fraction = %8.4f \n',AF_total)
fprintf(' \n')

% total number of indexed points in map without 'notIndexed' phase
Indexed_map_points = sum(length(ebsd(Phase_names(N_first_indexed_phase:numel(Phase_names)))));
% percentage of indexed point in map
Percent_indexed = 100*Indexed_map_points/Map_points;
% print to screen
fprintf(' \n')
fprintf(' Percentage indexed points in map = %5.1f \n',Percent_indexed)
fprintf(' \n')
%% Calculate the area fraction considering only indexed pixels

fprintf(' \n')
fprintf(' Area fractions based on minerals with EBSD indexed points only \n')
fprintf(' \n')
fprintf('   #      Phase       Points  Area fraction \n')
for i=N_first_indexed_phase:numel(Phase_names);
% indexed point for mineral
N_Points = length(ebsd(Phase_names(i)));
   if(N_Points > 0)
% area fraction for mineral
Area_Fractions(i) = N_Points/Indexed_map_points;
% retain first part of mineral name
P_Name = strtok(char(Phase_names{i}),' ');
      fprintf(' %3i %12s %10i %11.4f \n',...
      i,P_Name,N_Points,Area_Fractions(i))
   end
end
AF_total = sum((Area_Fractions(N_first_indexed_phase:numel(Phase_names))));
fprintf(' \n')
fprintf(' Total area fraction = %8.4f \n',AF_total)
fprintf(' \n')

%% Define elastic stiffness tensor of Olivine (Abramson et al., 1997 JGR)

M = [[320.5  68.15  71.6     0     0     0];...
    [ 68.15  196.5  76.8     0     0     0];...
    [  71.6   76.8 233.5     0     0     0];...
    [   0      0      0     64     0     0];...
    [   0      0      0      0    77     0];...
    [   0      0      0      0     0  78.7]];
% Define Olivine density (from the paper above, g/cm^3)
rho_olivine = 3.3550;
% Define Cartesian Tensor crystal symmetry & frame
CS_Tensor_olivine = crystalSymmetry('222', [4.762 10.225 5.994],...
    'mineral', 'olivine', 'color', 'light red')
% Define elastic stiffness tensor Cijkl with MTEX load tensor command
C_olivine = stiffnessTensor(M,CS_Tensor_olivine,'name','elastic stiffness',...
    'unit','GPa','density',rho_olivine)
%% Define elastic stiffness tensor of Enstatite (Chai et al. 1997 - JGR)

M =.... 
 [[  236.90   79.60   63.20    0.00    0.00    0.00];...
 [    79.60  180.50   56.80    0.00    0.00    0.00];...
 [    63.20   56.80  230.40    0.00    0.00    0.00];...
 [     0.00    0.00    0.00   84.30    0.00    0.00];...
 [     0.00    0.00    0.00    0.00   79.40    0.00];...
 [     0.00    0.00    0.00    0.00    0.00   80.10]];
rho_opx = 3.3060;
cs_Tensor_opx = crystalSymmetry('mmm',[ 18.2457  8.7984  5.1959],...
 [  90.0000  90.0000  90.0000]*degree,'x||a','z||c',...
 'mineral','Enstatite');
C_opx = stiffnessTensor(M,cs_Tensor_opx)
%% Define elastic stiffness tensor of Diopside (Isaak et al., 2005 - PCM)
M =.... 
 [[  228.10   78.80   70.20    0.00    7.90    0.00];...
 [    78.80  181.10   61.10    0.00    5.90    0.00];...
 [    70.20   61.10  245.40    0.00   39.70    0.00];...
 [     0.00    0.00    0.00   78.90    0.00    6.40];...
 [     7.90    5.90   39.70    0.00   68.20    0.00];...
 [     0.00    0.00    0.00    6.40    0.00   78.10]];

rho_cpx = 3.2860;
cs_Tensor_cpx = crystalSymmetry('121',[9.585  8.776  5.26],...
 [90.0000 105.8600  90.0000]*degree,'x||a*','z||c',...
 'mineral','Diopside');
crystalSymmetry('121', [9.585 8.776 5.26], [90,106.85,90]*degree,...
    'X||a*', 'Y||b', 'Z||c', 'mineral', 'diopside', 'color', 'light blue')
C_cpx = stiffnessTensor(M,cs_Tensor_cpx)

%% Let's calculate the olivine single crystal seismic velocities

[vp_ol,vs1_ol,vs2_ol,pp_ol,ps1_ol,ps2_ol] = C_olivine.velocity('harmonic');

% here Vp, Vs1 and Vs2 stands for the velocities of P, fast and slow
% S-waves respectively, where ps1 and ps2 are the polarization directions

%% Plot some single crystal seismic velocities
%
%  Let's first define some preferences

plota2east;
setMTEXpref('defaultColorMap',blue2redColorMap)

blackMarker = {'Marker','s','MarkerSize',10,'antipodal',...
  'MarkerEdgeColor','white','MarkerFaceColor','black','doNotDraw'};
whiteMarker = {'Marker','o','MarkerSize',10,'antipodal',...
  'MarkerEdgeColor','black','MarkerFaceColor','white','doNotDraw'};

titleOpt = {'visible','on','color','k'};

% Setup multiplot 
% define plot size [origin X,Y,Width,Height]
mtexFig = mtexFigure('position',[0 0 1000 1000]);

%  Vp : Plot P-wave velocity (km/s)

plot(vp_ol,'contourf','complete','upper','minmax')
mtexTitle('Vp (km/s)',titleOpt{:})

% Calculate maximum and minimum

[maxVp_ol, maxVpPos_ol] = max(vp_ol);
[minVp_ol, minVpPos_ol] = min(vp_ol);

% Calculate Vp anisotropy

AVp_qtz = 200*(maxVp_ol-minVp_ol) / (maxVp_ol+minVp_ol);

% Add some markers to help visualization

hold on
plot(maxVpPos_ol.symmetrise,blackMarker{:})
plot(minVpPos_ol.symmetrise,whiteMarker{:})
hold off
xlabel(['Vp Anisotropy = ',num2str(AVp_qtz,'%27.7f')],titleOpt{:})
drawNow(gcm,'figSize','large')

%% Plot S-wave anisotropy

% create a new axis
nextAxis
% Plot S-wave anisotropy (percent)
AVs_ol = 200*(vs1_ol-vs2_ol)./(vs1_ol+vs2_ol);
plot(AVs_ol,'contourf','complete','upper');
mtexTitle('S-wave anisotropy (%)',titleOpt{:})
% Max percentage anisotropy
[maxAVs_ol,maxAVsPos_ol] = max(AVs_ol);
[minAVs_ol,minAVsPos_ol] = min(AVs_ol);
xlabel(['Max Vs Anisotropy = ',num2str(maxAVs_ol,'%6.1f')],titleOpt{:})
% mark maximum with black square and minimum with white circle
hold on
plot(maxAVsPos_ol.symmetrise,blackMarker{:})
plot(minAVsPos_ol.symmetrise,whiteMarker{:})
hold off


%% Plot the fast shear wave (S1) polarization direction

nextAxis
plot(AVs_ol,'contourf','complete','upper');
mtexTitle('Vs1 polarization',titleOpt{:})
hold on
plot(ps1_ol,'linewidth',2,'color','black','doNotDraw')
hold off

% essentiall by adding nextAxis on the beginning of each section for a
% plot, you can have all your plots in one single figure. Once you finish,
% you may want to have a scalebar for all the plots, this can be done as

mtexColorbar
drawNow(gcm,'figSize','large')

%% Now let's estimate the elastic tensor of our sample
%
% First we need to calculate the ODF of the individual phases
%
odf_ol = calcDensity(ebsd('f').orientations,'halfwidth',10*degree)
odf_opx = calcDensity(ebsd('e').orientations,'halfwidth',10*degree)
odf_cpx = calcDensity(ebsd('d').orientations,'halfwidth',10*degree)

% Note that you do don't need to write the full name of each phase, only
% the initial, that works when phases start with different letters, you can
% setup this also in the import_wizard
%
% To calculate the elastic constant of each phase considering their
% orientations within this sample, you do

[CVoigt_ol_poly, CReuss_ol_poly, CHill_ol_poly] =  ...
  calcTensor(odf_ol,C_olivine)

[CVoigt_opx_poly, CReuss_opx_poly, CHill_opx_poly] =  ...
  calcTensor(odf_opx,C_opx)

[CVoigt_cpx_poly, CReuss_cpx_poly, CHill_cpx_poly] =  ...
  calcTensor(odf_cpx,C_cpx)

% Now to calculate the elastic tensor considering the three phases, you do

CHill_all = 0.81*CHill_ol_poly + 0.14*CHill_opx_poly + 0.05*CHill_cpx_poly

% And finally you calculate the seismic velocities

[vp_poly_all,vs1_poly_all,vs2_poly_all,pp_poly_all,ps1_poly_all,ps2_poly_all] = ...
    CHill_all.velocity('harmonic')

%% Plot P-wave velocity (km/s)


plota2east;
setMTEXpref('defaultColorMap',blue2redColorMap)

blackMarker = {'Marker','s','MarkerSize',10,'antipodal',...
  'MarkerEdgeColor','white','MarkerFaceColor','black','doNotDraw'};
whiteMarker = {'Marker','o','MarkerSize',10,'antipodal',...
  'MarkerEdgeColor','black','MarkerFaceColor','white','doNotDraw'};

titleOpt = {'visible','on','color','k'};

% Setup multiplot 
% define plot size [origin X,Y,Width,Height]
mtexFig = mtexFigure('position',[0 0 1000 1000]);


plot(vp_poly_all,'contourf','doNotDraw','complete','upper')
mtexTitle('Vp (km/s)',titleOpt{:})
% extrema
[maxVp_poly_all, maxVpPos_poly_all] = max(vp_poly_all);
[minVp_poly_all, minVpPos_poly_all] = min(vp_poly_all);
% percentage anisotropy
AVp_poly_all = 200*(maxVp_poly_all-minVp_poly_all) / (maxVp_poly_all...
    +minVp_poly_all);
% mark maximum with black square and minimum with white circle
hold on
plot(maxVpPos_poly_all,blackMarker{:})
plot(minVpPos_poly_all,whiteMarker{:})
hold off
% subTitle
xlabel(['Vp Anisotropy = ',num2str(AVp_poly_all,'%27.7f')],titleOpt{:})
drawNow(gcm,'figSize','large')

%% Plot fast shear-wave velocity S1 (km/s)

nextAxis
plot(vs1_poly_all,'contourf','doNotDraw','complete','upper');
mtexTitle('Vs1 (km/s)',titleOpt{:})
[maxS1_poly_all,maxS1pos_poly_all] = max(vs1_poly_all);
[minS1_poly_all,minS1pos_poly_all] = min(vs1_poly_all);
AVs1_poly_all=200*(maxS1_poly_all-minS1_poly_all)./(maxS1_poly_all+minS1_poly_all);
xlabel(['Vs1 Anisotropy = ',num2str(AVs1_poly_all,'%6.1f')],titleOpt{:})
hold on
plot(ps1_poly_all,'linewidth',2,'color','black')
hold on
plot(maxS1pos_poly_all,blackMarker{:})
plot(minS1pos_poly_all,whiteMarker{:})
hold off

%% Plot slow shear-wave velocity S2 (km/s)

nextAxis
plot(vs2_poly_all,'contourf','doNotDraw','complete','upper');
mtexTitle('Vs2 (km/s)',titleOpt{:})
% Percentage anisotropy
[maxS2_poly_all,maxS2pos_poly_all] = max(vs2_poly_all);
[minS2_poly_all,minS2pos_poly_all] = min(vs2_poly_all);
AVs2_poly_all=200*(maxS2_poly_all-minS2_poly_all)./(maxS2_poly_all+minS2_poly_all);
xlabel(['Vs2 Anisotropy = ',num2str(AVs2_poly_all,'%6.1f')],titleOpt{:})
hold on
plot(ps2_poly_all,'linewidth',2,'color','black')
% mark maximum with black square and minimum with white circle
hold on
plot(maxS2pos_poly_all,blackMarker{:})
plot(minS2pos_poly_all,whiteMarker{:})
hold off

%% Plot S-wave anisotropy (%)

nextAxis
AVs_poly_all = 200*(vs1_poly_all-vs2_poly_all)./(vs1_poly_all+vs2_poly_all);
plot(AVs_poly_all,'contourf','complete','upper');
mtexTitle('S-wave anisotropy (%)',titleOpt{:})
[maxAVs_poly_all,maxAVsPos_poly_all] = max(AVs_poly_all);
[minAVs_poly_all,minAVsPos_poly_all] = min(AVs_poly_all);
xlabel(['Max Vs Anisotropy = ',num2str(maxAVs_poly_all,'%6.1f')],titleOpt{:})
hold on
plot(maxAVsPos_poly_all,blackMarker{:})
plot(minAVsPos_poly_all,whiteMarker{:})
hold off

%% Plot Velocity difference Vs1-Vs2 (km/s) plus Vs1 polarizations

nextAxis
dVs_poly_all = vs1_poly_all-vs2_poly_all;
plot(dVs_poly_all,'contourf','complete','upper');
mtexTitle('dVs=Vs1-Vs2 (km/s)',titleOpt{:})
[maxdVs_poly_all,maxdVsPos_poly_all] = max(dVs_poly_all);
[mindVs_poly_all,mindVsPos_poly_all] = min(dVs_poly_all);
xlabel(['Max dVs (km/s) = ',num2str(maxdVs_poly_all,'%6.2f')],titleOpt{:})
hold on
plot(maxdVsPos_poly_all,blackMarker{:})
plot(mindVsPos_poly_all,whiteMarker{:})
hold off

%% Plot Vp/Vs1 ratio (no units)

nextAxis
vpvs1_poly_all = vp_poly_all./vs1_poly_all;
plot(vpvs1_poly_all,'contourf','complete','upper');
mtexTitle('Vp/Vs1',titleOpt{:})
% Percentage anisotropy
[maxVpVs1_poly_all,maxVpVs1Pos_poly_all] = max(vpvs1_poly_all);
[minVpVs1_poly_all,minVpVs1Pos_poly_all] = min(vpvs1_poly_all);
AVpVs1_poly_all=200*(maxVpVs1_poly_all-minVpVs1_poly_all)/(maxVpVs1_poly_all+minVpVs1_poly_all);
xlabel(['Vp/Vs1 Anisotropy = ',num2str(AVpVs1_poly_all,'%6.1f')],titleOpt{:})
% mark maximum with black square and minimum with white circle
hold on
plot(maxVpVs1Pos_poly_all,blackMarker{:})
plot(minVpVs1Pos_poly_all,whiteMarker{:})
hold off

%% Add colorbars in all pole figures and return default color code

mtexColorbar
drawNow(gcm,'figSize','large')
setMTEXpref('defaultColorMap',WhiteJetColorMap)
