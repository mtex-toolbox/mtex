%% Lankford coefficient
%
% The Lankford coefficient (also called Lankford value, R-value, or plastic
% strain ratio) is a measure of the plastic anisotropy of a rolled sheet
% metal. This scalar quantity is used extensively as an indicator of the
% formability of recrystallized low-carbon steel sheets.
% 
% The R-value can be determined experimentally, but also theoretically
% within the Taylor theory as it will be demonstrated below.

%% Data Setup
% In this demonstration we use a hcp titanium data set and start with some
% cleanup steps

mtexdata titanium
CS = ebsd.CS;

% grain reconstruction 
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

% remove small grains
ebsd(grains(grains.grainSize <= 5)) = [];

% recalculate the grains
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

plot(ebsd,ebsd.orientations);
hold all
plot(grains.boundary,'lineWidth',2);
hold off


%% The slip systems
% For the Taylor theory we need to carefully set up the relevant
% <slipSystem.index.html slip systems> and the corresponding critical
% resolved shear stresses. As we have an hcp material we choose

sS = [slipSystem.basal(CS,1),...
  slipSystem.prismatic2A(CS,66),...
  slipSystem.pyramidalCA(CS,80),...
  slipSystem.twinC1(CS,100)]

%% R-Value computation
% The computation of the R-value is done using the command <calcRValue.html
% |calcRValue|>. It solely depends on the texture provided by the mean
% orientations of the grains, weighted by the area of the grains and the
% angle $\theta$ between tensial direction and the ... direction.

theta = linspace(0,90*degree,19);
[R, minM, M] = calcRValue(grains.meanOrientation,sS,theta,'weights',grains.grainSize);

%%
% This is recreates Fig. 3.10 on page 74 of: William F. Hosford, The
% mechanics of crystals and textured polycrystals
% https://onlinelibrary.wiley.com/doi/epdf/10.1002/crat.2170290414
%
% Dependence of $M$ on $\rho = -d_{\epsilon}_Y / d_{\epsilon}_X =
% \frac{R}{1+R}$ for rolling and transverse direction tension tests for an
% ideal (1 1 0)[1 -1 2] Brass orientation. In the rolling direction test x
% = [1 -1 2], and in the transverse test x = [-1 1 1].

plot(linspace(0,1,11), M(:,[1,end]).','s-','lineWidth',1.5);
xlabel('{\rho} = -d{\epsilon}_Y / d{\epsilon}_X');
ylabel('Relative strength, M = {\sigma}_x / {\tau}');

legend('\theta=0^\circ','\theta=90^\circ','Location','north')

%%
% some text

plot(theta ./ degree,minM,'o-b','lineWidth',1.5);
xlabel('Angle to tensile direction, {\theta} (in degrees)');
ylabel('Min. relative strength, min(M) = min({\sigma}_x / {\tau}min(M))');

%%
% some text

plot(theta ./ degree,R,'o-r','lineWidth',1.5);
xlabel('Angle to tensile direction, {\theta} (in degrees)');
ylabel('R @ M_m_i_n, R = {\rho} / (1 - {\rho}) = -d{\epsilon}_Y / d{\epsilon}_Z');

