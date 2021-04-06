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
% We may transform an arbitrary ODF into its Fourier representation using
% the command <SO3FunHarmonic.SO3FunHarmonic.html SO3FunHarmonic> 

fodf = FourierODF(odf3,'bandwidth',32)

%%
% Within the variable |fodf| the Fourier coefficients are stored as the
% property |fodf.f_hat| in a linear order, i.e., the |fodf.f_hat(1)| is the
% zero order Fourier coefficient, |fodf.fhat(2:10)| are the first order
% Fourier coefficients that form a 3x3 matrix. Accordingly, we can extract
% the second order Fourier coefficients by

reshape(fodf.fhat(11:35),5,5)

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