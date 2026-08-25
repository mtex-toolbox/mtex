%% Harmonic Representation of Rotational Functions
%
%%
% Fourier series replace a complicated function by a weighted sum of known
% basis functions. On a circle those basis functions are sines and cosines;
% on the rotation group they are Wigner-D functions. Thus a rotational
% function $f\colon \mathcal{SO}(3) \to \mathbb C$ can be written as
%
% $$ f({\bf R}) = \sum_{n=0}^N \sum_{k,l = -n}^n \hat f_n^{k,l} \, \mathrm{D}_n^{k,l}({\bf R}) $$
%
% with Fourier coefficients $\hat f_n^{k,l}$ and the
% <WignerFunctions.html Wigner-D functions> $D_n^{k,l}$.
% The largest retained order $N$ is the *bandwidth*. Raising it resolves
% narrower features but increases storage and computation; truncating it is
% a controlled form of smoothing.
%
% Several normalizations of Wigner-D functions are used in the literature.
% MTEX uses an orthonormal basis with respect to the normalized measure on
% $\mathrm{SO}(3)$, so
%
% $$\| D_n^{k,l} \|_2 = 1$$
%
% for all $n,k,l$. Crystal and specimen symmetry restrict which coefficient
% combinations are admissible; MTEX applies those restrictions through the
% symmetries attached to the function. More on the basis is in
% <WignerFunctions.html Wigner-D functions>.
%
%%
% Start from an ODF reconstructed from pole figure data - any
% <SO3FunConcept.html SO3Fun> will do.
plottingConvention.default('y↑→x');
mtexdata dubna
odf = calcODF(pf,'resolution',5*degree,'zero_Range')
%%
% Converting to |SO3FunHarmonic| computes a finite harmonic approximation.
% Here we request bandwidth 32 explicitly.

f = SO3FunHarmonic(odf,'bandwidth',32)

%% Fourier Coefficients
%
% An |@SO3FunHarmonic| stores its complex Fourier coefficients in |f.fhat|.
% They are arranged in one vector: |f.fhat(1)| is the
% zero order Fourier coefficient, |f.fhat(2:10)| are the first order
% Fourier coefficients that form a 3x3 matrix and so on.
% Accordingly, we can extract the second order Fourier coefficients by

reshape(f.fhat(11:35),5,5)

%%
% A harmonic function can also be constructed by writing its coefficients
% down. Here $\hat f_0^{0,0} = 0.5$ and
% $\hat f_1 = \left(\begin{array}{rrr} 
% 1 & 4 & 7 \\ 
% 2 & 5 & 8 \\ 
% 3 & 6 & 9 \\ 
% \end{array}\right)$

f2 = SO3FunHarmonic([0.5,1:9]')

plot(f2)
%%
% Up to the chosen bandwidth, the coefficients completely characterize the
% rotational function. They also make many calculations algebraic. For
% example, orientation averages of second-rank single-crystal properties
% such as thermal expansion or conductivity use only low harmonic orders;
% fourth-rank elastic properties additionally involve order four. The
% effective property still depends on the single-crystal tensor--the ODF
% coefficients describe the texture part of the average.
%
% Moreover, the decay of the Fourier coefficients is directly related to
% the smoothness of the SO3Fun. The decay of the Fourier coefficients might
% also indicate the presence of a ghost effect, see
% <PoleFigure2ODFGhostCorrection.html Ghost Correction>.

%%
% The decay of the Fourier coefficients is shown in the plot
close all;
plotSpektra(f)


%% Functions Given by Fourier Coefficients
%
% To define a function by its *Fourier coefficients* ${\bf \hat{f}}$, pass
% them
% passed as a linearly ordered, complex valued vector of the form
%
% $$ {\bf \hat{f}} = [\hat{f}_0^{0,0},\hat{f}_1^{-1,-1},\ldots,\hat{f}_1^{1,1},\hat{f}_2^{-2,-2},\ldots,\hat{f}_N^{N,N}] $$
%
% where $n=0,\ldots,N$ denotes the order of the Fourier coefficients.

cs   = crystalSymmetry('1');    % crystal symmetry
fhat = [1;reshape(eye(3),[],1);reshape(eye(5),[],1)]; % Fourier coefficients
fExample = SO3FunHarmonic(fhat,cs)

plot(fExample,'sections',6,'silent','sigma')

%%

plotPDF(fExample,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% A coefficient vector defines a rotational function, but not automatically
% a valid ODF. An ODF must additionally be real, nonnegative and normalized
% to mean one. Truncating the series of a sharp positive ODF can also create
% small negative undershoots, just as a truncated ordinary Fourier series
% can ring near a sharp edge.


%% Harmonic Representation of a General SO3Fun
%
% Nothing in the harmonic representation requires the function to be an
% ODF. Any function on the rotation group can be expanded, and the
% expansion is computed by <SO3FunHarmonic.quadrature.html |quadrature|>.
% As an example we take the misorientation angle to a fixed orientation,
% which is a perfectly ordinary function on SO(3) but is neither
% non negative nor normalized.

cs = crystalSymmetry('432');
oriRef = orientation.byEuler(30*degree,50*degree,10*degree,cs);

f = SO3FunHandle(@(ori) angle(ori,oriRef)./degree,cs)

%%
% Its harmonic approximation at bandwidth 32 is

fHarm = SO3FunHarmonic.quadrature(f,'bandwidth',32)

%%
% and it reproduces the original function reasonably well away from the
% cusp at |oriRef|

rng(0)
ori = orientation.rand(1000,cs);

max(abs(f.eval(ori) - fHarm.eval(ori)))

%%
% The reason for the sizeable error is visible in the decay of the Fourier
% coefficients - the function is continuous but not differentiable at
% |oriRef| and at the boundary of the fundamental region, so its
% coefficients decay only slowly and truncation is felt everywhere.

close all
plotSpektra(fHarm)

%%
% This is the general rule stated above, seen from the other side: the
% smoother the function, the faster its Fourier coefficients decay and the
% lower the bandwidth needed to represent it.

plotSection(fHarm,'sigma')
mtexColorbar('title','misorientation angle in degree')

%#ok<*NOPTS>

%% Next
%
% The functions this series is built from are
% <WignerFunctions.html Wigner-D Functions>, and what can be computed with
% a harmonic representation is <SO3FunOperations.html Operations>. The
% reconstruction that produced the ODF above is
% <PoleFigure2ODF.html Reconstructing an ODF>.
