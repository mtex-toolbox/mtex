%% Harmonic Representation of Rotational Functions
%

%%
% Similarly as periodic functions may be represented as weighted sums of
% sines and cosines a rotational function $f\colon \mathcal{SO}(3)\to\mathbb C$ 
% can be written as a series of the form
%
% $$ f({\bf R}) = \sum_{n=0}^N \sum_{k,l = -n}^n \hat f_n^{k,l} \, \mathrm{D}_n^{k,l}({\bf R}) $$
%
% with respect to Fourier coefficients $\hat f_n^{k,l}$ and the so called
% Wigner-D functions $D_n^{k,l}({\bf R})$.
% 
% In terms of Matthies (ZYZ-convention) Euler angles 
% ${\bf R} = ${\bf R}(\alpha,\beta,\gamma)$ the $L_2$-normalized Wigner-D 
% function of degree $n\in\mathbb N$ and orders $k,l \in \{-n,\dots,n\}$ is
% defined by
%
% $$ D_n^{k,l}({\bf R}) = \sqrt{2n+1} \, \mathrm e^{\mathrm i k\gamma} \mathrm d_n^{k,l}(\cos\beta) \,e^{\mathrm i l\alpha} $$
%
% where $d_n^{k,l}$, denotes the real valued Wigner-d function, which is
% defined by some constants
%
% $$ a &=|k-l|,\\
% b &=|k+l|,\\
% s &= n- \frac{a+b}2 = n - \max\{|k|,|l|\},\\
% \nu &= \begin{cases}
%           0 	& \text{falls } l \geq k,\\
%           k+l & \text{sonst}
%         \end{cases} $$
%
% and the formula
%
% $$ d_n^{k,l}(x) =  \binom{2n-s}{s+a}^{\frac12} \binom{s+b}{b}^{-\frac12} \left(\frac{1-x}{2}\right)^{\frac{a}2} \left(\frac{1+x}{2}\right)^{\frac{b}2} P_s^{a,b}(x)$$
%
% were $P_s^{a,b}$ denotes the corresponding Jacobi polynomial.
%
%%
%
% We construct an arbitrary ODF which generally is an SO3Fun:
mtexdata dubna
odf = calcODF(pf,'resolution',5*degree,'zero_Range')
%%
% Now we may transform an arbitrary SO3Fun into its Fourier representation 
% using the command <SO3FunHarmonic.SO3FunHarmonic.html SO3FunHarmonic> 

f = SO3FunHarmonic(odf,'bandwidth',32)

%% Fourier Coefficients
%
% Within the class |@SO3FunHarmonic| rotational functions are represented by
% their complex valued Fourier coefficients which are stored in the field 
% |fun.fhat|. 
% They are stored in a linear order, which means |f.fhat(1)| is the
% zero order Fourier coefficient, |f.fhat(2:10)| are the first order
% Fourier coefficients that form a 3x3 matrix and so on.
% Accordingly, we can extract the second order Fourier coefficients by

reshape(f.fhat(11:35),5,5)

%%
% As an additional example lets define a harmonic function which Fourier
% coefficients are $\hat f_0^{0,0} = 0.5$ and 
% $\hat f_1 = \begin{array}{rrr} 
% 1 & 4 & 7 \\ 
% 2 & 5 & 8 \\ 
% 3 & 6 & 9 \\ 
% \end{array}$

f2 = SO3FunHarmonic([0.5,1:9]')

plot(f2)
%%
% The Fourier coefficients $\hat f_n^{k,l}$ allow us a complete 
% characterization of the rotational function. They are of particular 
% importance for the calculation of mean macroscopic properties e.g. 
% the second order Fourier coefficients characterize thermal expansion, 
% optical refraction index, and electrical conductivity whereas the 
% fourth order Fourier coefficients characterize the elastic properties 
% of the specimen.
%
% Moreover, the decay of the Fourier coefficients is directly related to
% the smoothness of the SO3Fun. The decay of the Fourier coefficients might
% also hint for the presents of a ghost effect. See
% <PoleFigure2ODFGhostCorrection.html Ghost Correction>.

%%
% The decay of the Fourier coefficients is shown in the plot
close all;
plotSpektra(f)


%% ODFs given by Fourier coefficients
%
% In order to define an ODF by it *Fourier coefficients* ${\bf \hat{f}}$, 
% they has to be given as a literally ordered, complex valued
% vector of the form
%
% $$ {\bf \hat{f}} = [\hat{f}_0^{0,0},\hat{f}_1^{-1,-1},\ldots,\hat{f}_1^{1,1},\hat{f}_2^{-2,-2},\ldots,\hat{f}_N^{N,N}] $$
%
% where $n=0,\ldots,N$ denotes the order of the Fourier coefficients.

cs   = crystalSymmetry('1');    % crystal symmetry
fhat = [1;reshape(eye(3),[],1);reshape(eye(5),[],1)]; % Fourier coefficients
odf = SO3FunHarmonic(fhat,cs)

plot(odf,'sections',6,'silent','sigma')

%%

plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%% TODO: Add some non ODF example for an SO3Fun
%
%

