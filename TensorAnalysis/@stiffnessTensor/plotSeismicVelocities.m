function plotSeismicVelocities(C,varargin)
%
%
% Syntax
%   % stiffness tensor with density!
%   C = stiffnessTensor(M,cs_tensor,'density',rho)
%   multiSeismicPlot(C)
%
% Input
%  C - @stiffnessTensor
%
% Options
%  upper / lower - plot upper or lower hemisphere
%  symmetriseMinMax - plot min/max symmetrised
%
% Description
%
% The layout of the plot is
%
% Plot matrix of anisotropic seismic properties
%        1 Vp        2 AVs      3 S1 polarizations  4 Vs1
%        5 Vs2       6 dVs      7 Vp/Vs1            8 Vp/Vs2
%


% Compute seismic velocities as functions
% using option velocity(C,[]) or C.velocity 
% BOTH generate velocities on sphere using harmonic method
% OR using the traditional velocity(C,x) where x is the propagation
% directions , many directions or a grid.
% such as XY_grid = equispacedS2Grid('upper','resolution',1*degree)
% [vp,vs1,vs2,pp,ps1,ps2] = velocity(C,XY_grid)
% Using a user defined grid use classical method not harmonic method.

% Seismic velocities as functions on the sphere with harmonic method
% is recommended for a smooth representation that actuately respects
% the symmetry of single crystals and can be plotted in 3D.
%
[vp,vs1,vs2,pp,ps1,ps2] = velocity(C);
%
% you can sample the velocity values in any x,y,z direction by using
% vp_xyz = eval(vp,vector3d(x,y,z)) or
% vp_rho_theta = eval(vp,vector3d('rho',45*degree,'theta',90*degree))
% etc
%
%**************************************************************************
% Plotting section
%**************************************************************************

% set colour map to seismic color map : red2blueColorMap
% Red = slow to Blue = fast in Seismology

if ~check_option(varargin,'lower'), varargin = [varargin,'upper']; end

setMTEXpref('defaultColorMap',red2blueColorMap)

% some options
ms = get_option(varargin,'MarkerSize',10);
blackMarker = {'Marker','s','MarkerSize',ms,'antipodal',...
  'MarkerEdgeColor','white','MarkerFaceColor','black','doNotDraw'};
whiteMarker = {'Marker','o','MarkerSize',ms,'antipodal',...
  'MarkerEdgeColor','black','MarkerFaceColor','white','doNotDraw'};

% some global options for the titles
titleOpt = {'visible','on','color','k'};

% setup multiplot
mtexFig = newMtexFigure('figSize','huge','layout',[2 3]);

% Standard Seismic plot with 6 subplots in 2 by 3 matrix
%
% Plot matrix layout 2 by 3
%--------------------------------------------------------------------------
%        1 Vp        2 AVs      3 S1 polarizations
%        4 Vs2       5 Vp/Vs1   6 Vp/Vs2
%--------------------------------------------------------------------------
%**************************************************************************
% 1 Vp : Plot P-wave velocity (km/s)
%**************************************************************************

% Plot P-wave velocity (km/s)
plot(vp,'contourf','complete','doNotDraw',varargin{:})
mtexTitle('Vp (km/s)','doNotDraw',titleOpt{:})

% extrema
[maxVp, maxVpPos] = max(vp);
[minVp, minVpPos] = min(vp);

% percentage anisotropy
AVp = 200*(maxVp-minVp)./(maxVp+minVp);

% mark maximum with black square and minimum with white circle
hold on
if check_option(varargin,'symmetriseMinMax')
  plot(maxVpPos.symmetrise,blackMarker{:})
  plot(minVpPos.symmetrise,whiteMarker{:})
else
  plot(maxVpPos(1),blackMarker{:})
  plot(minVpPos(1),whiteMarker{:})    
end
hold off

% subTitle
xlabel(['Vp Anisotropy = ',num2str(AVp,'%6.1f')],titleOpt{:})
%**************************************************************************
% 2 AVs : Plot S-wave anisotropy percentage for each propagation direction
% defined as AVs = 200*(Vs1-Vs2)/(Vs1+Vs2)
%**************************************************************************

% create a new axis
nextAxis(1,2)

% Plot S-wave anisotropy (percent)
AVs = 200*(vs1-vs2)./(vs1+vs2);
plot(AVs,'contourf','complete','doNotDraw',varargin{:});
mtexTitle('S-wave anisotropy (%)','doNotDraw',titleOpt{:})

% Max percentage anisotropy
[maxAVs,maxAVsPos] = max(AVs);
[minAVs,minAVsPos] = min(AVs);

xlabel(['Max Vs Anisotropy = ',num2str(maxAVs,'%6.1f')],titleOpt{:})

% mark maximum with black square and minimum with white circle
hold on
if check_option(varargin,'symmetriseMinMax')
  plot(maxAVsPos.symmetrise,blackMarker{:})
  plot(minAVsPos.symmetrise,whiteMarker{:})
else
  plot(maxAVsPos(1),blackMarker{:})
  plot(minAVsPos(1),whiteMarker{:})
end
hold off

%**************************************************************************
% 3 Vs1 : Plot Vs1 velocities (km/s) with polarization
%**************************************************************************
% create a new axis
nextAxis(1,3)

plot(vs1,'contourf','doNotDraw','complete',varargin{:});
mtexTitle('Vs1 (km/s)','doNotDraw',titleOpt{:})

% Percentage anisotropy
[maxS1,maxS1pos] = max(vs1);
[minS1,minS1pos] = min(vs1);
AVs1=200*(maxS1-minS1)./(maxS1+minS1);

xlabel(['Vs1 Anisotropy = ',num2str(AVs1,'%6.1f')],titleOpt{:}) 

hold on
plot(ps1,'linewidth',2,'color','black')

% mark maximum with black square and minimum with white circle
hold on
if check_option(varargin,'symmetriseMinMax')
   plot(maxS1pos.symmetrise,blackMarker{:})
   plot(minS1pos.symmetrise,whiteMarker{:})
else
   plot(maxS1pos(1),blackMarker{:})
   plot(minS1pos(1),whiteMarker{:})
end
hold off

%**************************************************************************
% 4 Vs2 : Plot Vs2 velocities (km/s)
%**************************************************************************
% create a new axis
nextAxis(2,1)

plot(vs2,'contourf','doNotDraw','complete',varargin{:});
mtexTitle('Vs2 (km/s)','doNotDraw',titleOpt{:})

% Percentage anisotropy
[maxS2,maxS2pos] = max(vs2);
[minS2,minS2pos] = min(vs2);
AVs2=200*(maxS2-minS2)./(maxS2+minS2);
xlabel(['Vs2 Anisotropy = ',num2str(AVs2,'%6.1f')],titleOpt{:})

hold on
plot(ps2,'linewidth',2,'color','black')

% mark maximum with black square and minimum with white circle
hold on
if check_option(varargin,'symmetriseMinMax')
  plot(maxS2pos.symmetrise,blackMarker{:})
  plot(minS2pos.symmetrise,whiteMarker{:})
else
  plot(maxS2pos(1),blackMarker{:})
  plot(minS2pos(1),whiteMarker{:})
end

hold off
%**************************************************************************
% 5 Vp/Vs1 : Plot Vp/Vs1 ratio (no units)
%**************************************************************************
% create a new axis
nextAxis

vpvs1 = vp./vs1;
plot(vpvs1,'contourf','complete','doNotDraw',varargin{:});
mtexTitle('Vp/Vs1','doNotDraw',titleOpt{:})

% Percentage anisotropy
[maxVpVs1,maxVpVs1Pos] = max(vpvs1);
[minVpVs1,minVpVs1Pos] = min(vpvs1);
AVpVs1=200*(maxVpVs1-minVpVs1)./(maxVpVs1+minVpVs1);

xlabel(['Vp/Vs1 Anisotropy = ',num2str(AVpVs1,'%6.1f')],titleOpt{:})

% mark maximum with black square and minimum with white circle
hold on
if check_option(varargin,'symmetriseMinMax')
  plot(maxVpVs1Pos.symmetrise,blackMarker{:})
  plot(minVpVs1Pos.symmetrise,whiteMarker{:})
else
  plot(maxVpVs1Pos(1),blackMarker{:})
  plot(minVpVs1Pos(1),whiteMarker{:})
end
hold off
%**************************************************************************
% 6 Vp/Vs2 : Plot Vp/Vs2 ratio (no units)
%**************************************************************************
% create a new axis
nextAxis

vpvs2 = vp./vs2;
plot(vpvs2,'contourf','complete','doNotDraw',varargin{:});
mtexTitle('Vp/Vs2','doNotDraw',titleOpt{:})

% Percentage anisotropy
[maxVpVs2,maxVpVs2Pos] = max(vpvs2);
[minVpVs2,minVpVs2Pos] = min(vpvs2);
AVpVs2=200*(maxVpVs2-minVpVs2)./(maxVpVs2+minVpVs2);

xlabel(['Vp/Vs2 Anisotropy = ',num2str(AVpVs2,'%6.1f')],titleOpt{:})

% mark maximum with black square and minimum with white circle
hold on
if check_option(varargin,'symmetriseMinMax')
  plot(maxVpVs2Pos.symmetrise,blackMarker{:})
  plot(minVpVs2Pos.symmetrise,whiteMarker{:})
else
  plot(maxVpVs2Pos(1),blackMarker{:})
  plot(minVpVs2Pos(1),whiteMarker{:})
end
hold off
%**************************************************************************
% add colorbars to all plots and save plot
%**************************************************************************

mtexColorbar('figSize','huge')

%**************************************************************************
% reset to default MTEX colormap
%**************************************************************************
setMTEXpref('defaultColorMap',WhiteJetColorMap);
end

