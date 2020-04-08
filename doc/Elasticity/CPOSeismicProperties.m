%% Plot seismic wave velocities and polarization directions for aggregates
%
%%
% In this section we will calculate the elastic properties of an aggregate
% and plot its seismic properties in pole figures that can be directly
% compare to the pole figures for CPO
%
% Let's first import an example dataset from the MTEX toolbox

mtexdata forsterite

%%
% This dataset consists of the three main phases, olivine, enstatite and
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
% 1997 (Journal of Geophysical Research) with respect to the crystal reference frame

CS_Tensor_olivine = crystalSymmetry('222', [4.762 10.225 5.994],...
    'mineral', 'olivine', 'color', 'light red');
  
%%
% and the density in g/cm^3

rho_olivine = 3.3550;

%%
% by the coefficients $C_{ij}$ in Voigt matrix notation

Cij = [[320.5  68.15  71.6     0     0     0];...
  [ 68.15  196.5  76.8     0     0     0];...
  [  71.6   76.8 233.5     0     0     0];...
  [   0      0      0     64     0     0];...
  [   0      0      0      0    77     0];...
  [   0      0      0      0     0  78.7]];

%%
% In order to define the stiffness tensor as an MTEX variable we use the
% command @stiffnessTensor.

C_olivine = stiffnessTensor(Cij,CS_Tensor_olivine,'density',rho_olivine);

%%
% Note that when defining a single crystal tensor we shall always specify
% the crystal reference system which has been used to represent the tensor
% by its coordinates $c_{ijkl}$. 
%
% Now we define the stiffness tensor of enstatite, reported by Chai et al. 
% 1997 (Journal of Geophysical Research)

% the crystal reference system
cs_Tensor_opx = crystalSymmetry('mmm',[ 18.2457  8.7984  5.1959],...
  [  90.0000  90.0000  90.0000]*degree,'x||a','z||c',...
  'mineral','Enstatite');

% the density
rho_opx = 3.3060;

% the tensor coefficients
Cij =....
  [[  236.90   79.60   63.20    0.00    0.00    0.00];...
  [    79.60  180.50   56.80    0.00    0.00    0.00];...
  [    63.20   56.80  230.40    0.00    0.00    0.00];...
  [     0.00    0.00    0.00   84.30    0.00    0.00];...
  [     0.00    0.00    0.00    0.00   79.40    0.00];...
  [     0.00    0.00    0.00    0.00    0.00   80.10]];

% define the tensor
C_opx = stiffnessTensor(Cij,cs_Tensor_opx,'density',rho_opx);

%%
% For Diopside coefficients where reported in Isaak et al., 
% 2005 - Physics and Chemistry of Minerals)

% the crystal reference system
cs_Tensor_cpx = crystalSymmetry('121',[9.585  8.776  5.26],...
  [90.0000 105.8600  90.0000]*degree,'x||a*','z||c',...
  'mineral','Diopside');

% the density
rho_cpx = 3.2860;

% the tensor coefficients
Cij =.... 
  [[  228.10   78.80   70.20    0.00    7.90    0.00];...
  [    78.80  181.10   61.10    0.00    5.90    0.00];...
  [    70.20   61.10  245.40    0.00   39.70    0.00];...
  [     0.00    0.00    0.00   78.90    0.00    6.40];...
  [     7.90    5.90   39.70    0.00   68.20    0.00];...
  [     0.00    0.00    0.00    6.40    0.00   78.10]];

% define the tensor
C_cpx = stiffnessTensor(Cij,cs_Tensor_cpx,'density',rho_cpx);

%% Single crystal seismic velocities
%
% The single crystal seismic velocites can be computed by the command
% <stiffnessTensor.velocity.html |velocity|> and are explained in more
% detail <WaveVelocities.html here>. At this point we simply use the
% command <stiffnessTensor.plotSeismicVelocities.html
% |plotSeismicVelocities|> to get an overview of the single crystal seismic
% properties.

plotSeismicVelocities(C_olivine)

% lets add the crystal axes to the second plot
nextAxis(1,2)
hold on
text(Miller({1,0,0},{0,1,0},{0,0,1},CS_Tensor_olivine),...
  {'[100]','[010]','[001]'},'backgroundColor','w')
hold off

%% Bulk elastic tensor from EBSD data
%
% Combining the EBSD data and the single crystal stiffness tensors we can
% estimate an bulk stiffness tensor by computing Voigt, Reuss or Hill
% averages. Tensor averages are explained in more detail in
% <TensorAverage.html this section>. Here we use the command
% <EBSD.calcTensor.html calcTensor>

[CVoigt, CReuss, CHill] = calcTensor(ebsd,C_olivine,C_opx,C_cpx);

%%
% For visualizing the polycrystal wave velocities we again use the command
% <stiffnessTensor.plotSeismicVelocities.html |plotSeismicVelocities|>

plotSeismicVelocities(CHill)

%% Bulk elastic tensor from ODFs
%
% For large data sets the computation of the average stiffness tensor from
% the EBSD data might be slow. In such cases it can be faster to first
% estimate an ODF for each individual phase

odf_ol = calcDensity(ebsd('f').orientations,'halfwidth',10*degree);
odf_opx = calcDensity(ebsd('e').orientations,'halfwidth',10*degree);
odf_cpx = calcDensity(ebsd('d').orientations,'halfwidth',10*degree);

%%
% Note that you do don't need to write the full name of each phase, only
% the initial, that works when phases start with different letters. Also 
% note that although we use an EBSD dataset in this example, you can perform the
% same calculations with CPO data obtain by other methods (e.g. x-ray/neutron
% diffraction) as you only need the ODF variable for the calculations
%
% To calculate the average stiffness tensor from the ODFs we first compute
% them from each phase seperately

[CVoigt_ol, CReuss_ol, CHill_ol]    = mean(C_olivine,odf_ol);
[CVoigt_opx, CReuss_opx, CHill_opx] = mean(C_opx,odf_opx);
[CVoigt_cpx, CReuss_cpx, CHill_cpx] = mean(C_cpx,odf_cpx);

%%
% and then take their average weighted according the volume of each phase

vol_ol  = length(ebsd('f')) ./ length(ebsd('indexed'));
vol_opx = length(ebsd('e')) ./ length(ebsd('indexed'));
vol_cpx = length(ebsd('d')) ./ length(ebsd('indexed'));

CHill = vol_ol * CHill_ol + vol_opx * CHill_opx + vol_cpx * CHill_cpx;

%%
% Finally, we visualize the polycrystal wave velocities as above

plotSeismicVelocities(CHill)
