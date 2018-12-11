%% Characterizing ODFs
% Explains how to analyze ODFs, i.e. how to compute modal orientations,
% texture index, volume portions, Fourier coefficients and pole figures.
%
%% Open in Editor
%
%% Contents
%
%%
% *Some Sample ODFs*
%
% Let us first begin with some constructed ODFs to be analyzed below

%%
% A bimodal ODF:
cs = crystalSymmetry('mmm');
odf1 = unimodalODF(orientation.byEuler(0,0,0,cs)) + ...
  unimodalODF(orientation.byEuler(30*degree,0,0,cs))

%%
% A fibre ODF:

odf2 = fibreODF(Miller(0,0,1,cs),xvector)

%%
% An ODF estimated from diffraction data

mtexdata dubna

odf3 = calcODF(pf,'resolution',5*degree,'zero_Range')


%% Modal Orientations
% The modal orientation of an ODF is the crystallographic prefered
% orientation of the texture. It is characterized as the maximum of the
% ODF. In MTEX it can be computed by the command
% <ODF.calcModes.html calcModes>

%%
% Determine the modalorientation as an
% <orientation_index.html orientation>:
center = calcModes(odf3)

%%
% Lets mark this prefered orientation in the pole figures

plotPDF(odf3,h,'antipodal','superposition',c);
annotate(center,'marker','s','MarkerFaceColor','black')

%% Texture Characteristics
%
% Texture characteristics are used for a rough classification of ODF into
% sharp and weak ones. The two most common texture characteristics are the
% <ODF.entropy.html entropy> and the
% <ODF.textureindex.html texture index>.

%%
% Compute the texture index:
textureindex(odf1)

%%
% Compute the entropy:
entropy(odf2)


%% Volume Portions
%
% Volume portions describes the relative volume of crystals having a
% certain orientation. The relative volume of crystals having a orientation
% close to a given orientation is computed by the command
% <ODF.volume.html volume> and the relative volume of crystals having a
% orientation close to a given fibre is computed by the command
% <ODF.fibreVolume.html fibreVolume>

%%
% The relative volume in percent of crystals with missorientation maximum
% 30 degree from the modal orientation:
volume(odf3,calcModes(odf3),30*degree)*100

%%
% The relative volume of crystals with missorientation maximum 20 degree
% from the prefered fibre in percent:
% TODO
%fibreVolume(odf2,Miller(0,0,1),xvector,20*degree) * 100


%% Fourier Coefficients
%
% The Fourier coefficients allow for a complete characterization of the
% ODF. The are of particular importance for the calculation of mean
% macroscopic properties e.g. the second order Fourier coefficients
% characterize thermal expansion, optical refraction index, and
% electrical conductivity whereas the fourth order Fourier
% coefficients characterize the elastic properties of the specimen.
% Moreover, the decay of the Fourier coefficients is directly related to
% the smoothness of the ODF. The decay of the Fourier coefficients might
% also hint for the presents of a ghost effect. See
% <ghost_demo.html ghost effect>.

%%
% transform into an odf given by Fourier coefficients
fodf = FourierODF(odf3,32)

%%
% The Fourier coefficients of order 2:
reshape(fodf.components{1}.f_hat(11:35),5,5)

%%
% The decay of the Fourier coefficients:
close all;
plotFourier(fodf)

%% Pole Figures and Values at Specific Orientations
%
% Using the command <ODF.eval.html eval> any ODF can be evaluated at any
% (set of) orientation(s).

odf1.eval(orientation.byEuler(0*degree,20*degree,30*degree,cs))

%%
% For a more complex example let us define a fibre and plot the ODF there.

fibre = orientation(fibre(Miller(1,0,0,cs),yvector));

plot(odf2.eval(fibre))

%%
% Evaluation of the corresponding pole figure or inverse pole figure is
% done using the command <ODF.calcPDF.html calcPDF>.

odf2.calcPDF(Miller(1,0,0,cs),xvector)

%% Extract Internal Representation
% The internal representation of the ODF can be addressed by the command

properties(odf3.components{1})

%%
% The properties in this list can be accessed by

odf3.components{1}.center

odf3.components{1}.psi
