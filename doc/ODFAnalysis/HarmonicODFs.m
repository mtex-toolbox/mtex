%% Harmonic Series Expansion of an ODF
%
%%

mtexdata dubna

odf3 = calcODF(pf,'resolution',5*degree,'zero_Range')


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
% <PoleFigure2ODFGhostCorrection.html Ghost Correction>.

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


%% ODFs given by Fourier coefficients
%
% In order to define a ODF by it *Fourier coefficients* the Fourier
% coefficients *C* has to be given as a literally ordered, complex valued
% vector of the form
%
% $$ C = [C_0,C_1^{-1-1},\ldots,C_1^{11},C_2^{-2-2},\ldots,C_L^{LL}] $$
%
% where $l=0,\ldots,L$ denotes the order of the Fourier coefficients.

cs   = crystalSymmetry('1');    % crystal symmetry
C = [1;reshape(eye(3),[],1);reshape(eye(5),[],1)]; % Fourier coefficients
odf = FourierODF(C,cs)

plot(odf,'sections',6,'silent','sigma')

%%

plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')