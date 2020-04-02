%% Plot seismic wave velocities and polarization directions
%
%%
%  In this section we will calculate the elastic properties of an aggregate
%  and plot its seismic properties in pole figures that can be directly
%  compare to the pole figures for CPO
%
%  Let's first import an example dataset from the MTEX toolboox

mtexdata forsterite

%%
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
% horizontal. We can correct the data by rotating the whole dataset by 90
% degree around the z-axis

ebsd = rotate(ebsd,rotation('axis',-zvector,'angle',90*degree));

plot(ebsd)

%% Import the elastic stiffness tensors
%
% The elastic stiffness tensor of Olivine was reported in Abramson et al.,
% 1997 JGR with respect to the crystal reference frame

CS_Tensor_olivine = crystalSymmetry('222', [4.762 10.225 5.994],...
    'mineral', 'olivine', 'color', 'light red');
  
%%
% and the density in g/cm^3

rho_olivine = 3.3550;

%%
% by the coefficients $C_{ij}$ in Voigt matrix notation

M = [[320.5  68.15  71.6     0     0     0];...
  [ 68.15  196.5  76.8     0     0     0];...
  [  71.6   76.8 233.5     0     0     0];...
  [   0      0      0     64     0     0];...
  [   0      0      0      0    77     0];...
  [   0      0      0      0     0  78.7]];


%%
% In order to define the stiffness tensor as an MTEX variable we use the
% command @stiffnessTensor.

C_olivine = stiffnessTensor(M,CS_Tensor_olivine,'density',rho_olivine)

%%
% Note that when defining a single crystal tensor we shall always specify
% the crystal reference system which has been used to represent the tensor
% by its coordinates $C_{ijkl}$. 
%
% Analogously, we next define the stiffness tensor of Enstatite and
% Diopside. For Enstatite we use the coefficients reportet in (Chai et al.
% 1997 - JGR)

% the crystal reference system
cs_Tensor_opx = crystalSymmetry('mmm',[ 18.2457  8.7984  5.1959],...
  [  90.0000  90.0000  90.0000]*degree,'x||a','z||c',...
  'mineral','Enstatite');

% the density
rho_opx = 3.3060;

% the tensor coefficients
M =....
  [[  236.90   79.60   63.20    0.00    0.00    0.00];...
  [    79.60  180.50   56.80    0.00    0.00    0.00];...
  [    63.20   56.80  230.40    0.00    0.00    0.00];...
  [     0.00    0.00    0.00   84.30    0.00    0.00];...
  [     0.00    0.00    0.00    0.00   79.40    0.00];...
  [     0.00    0.00    0.00    0.00    0.00   80.10]];

% define the tensor
C_opx = stiffnessTensor(M,cs_Tensor_opx,'density',rho_opx)

%%
% For Diposide coefficients where reported in (Isaak et al., 2005 - PCM)

% the crystal reference system
cs_Tensor_cpx = crystalSymmetry('121',[9.585  8.776  5.26],...
  [90.0000 105.8600  90.0000]*degree,'x||a*','z||c',...
  'mineral','Diopside');

% the density
rho_cpx = 3.2860;

% the tensor coefficients
M =.... 
  [[  228.10   78.80   70.20    0.00    7.90    0.00];...
  [    78.80  181.10   61.10    0.00    5.90    0.00];...
  [    70.20   61.10  245.40    0.00   39.70    0.00];...
  [     0.00    0.00    0.00   78.90    0.00    6.40];...
  [     7.90    5.90   39.70    0.00   68.20    0.00];...
  [     0.00    0.00    0.00    6.40    0.00   78.10]];

% define the tensor
C_cpx = stiffnessTensor(M,cs_Tensor_cpx)

%% Single crystal seismic velocities
%
% We start by calculating the single crystal seismic velocities of Olivine
% using the command <stiffnessTensor.velocity.html |velocity|>

[vp_ol,vs1_ol,vs2_ol,pp_ol,ps1_ol,ps2_ol] = C_olivine.velocity('harmonic');

%%
% As output we obtain three <S2FunConcept.html spherical functions>
% |vp_ol|, |vs1_ol| and |vs2_ol| representing the velocities of P, and fast
% and slow S-waves respectively in dependency of the propagation direction.
% The remaining three output variables |pp_ol|, |ps1_ol|, |ps2_ol| are
% <S2FunAxisField.html spherical vector fields> representing the
% polarization directions of these wave as functions of the propagation
% direction.

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
%
% essentiall by adding nextAxis on the beginning of each section for a
% plot, you can have all your plots in one single figure. Once you finish,
% you may want to have a scalebar for all the plots, this can be done as

nextAxis
plot(AVs_ol,'contourf','complete','upper');
mtexTitle('Vs1 polarization',titleOpt{:})
hold on
plot(ps1_ol,'linewidth',2,'color','black','doNotDraw')
hold off

mtexColorbar
drawNow(gcm,'figSize','large')

%% Now let's estimate the elastic tensor of our sample
%
% First we need to calculate the ODF of the individual phases

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
