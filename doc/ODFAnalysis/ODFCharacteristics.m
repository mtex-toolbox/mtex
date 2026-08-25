%% ODF Characteristics
%
%%
% An ODF is a function on a three dimensional space, and no plot of it fits
% in a sentence. A handful of numbers do: where the texture is strongest,
% how sharp it is, and what fraction of the material belongs to a given
% component. These are the numbers a paper quotes.

plottingConvention.default('y↑→x');

%% Three ODFs to Measure
%
% A bimodal one, built as a mixture so that its mean stays 1:

cs = crystalSymmetry('mmm');
odf1 = 0.5*unimodalODF(orientation.byEuler(0,0,0,cs)) + ...
  0.5*unimodalODF(orientation.byEuler(30*degree,0,0,cs))

%%
% a fibre ODF:

f001_x = fibre(Miller(0,0,1,cs),vector3d.X)

%%

odf2 = fibreODF(f001_x)

%%
% and one estimated from diffraction data:

mtexdata dubna

%%

odf3 = calcODF(pf,'resolution',5*degree,'zero_Range')

%% The Modal Orientation
%
% The strongest orientation of a texture - its mode - is the second output
% of <SO3Fun.max.html |max|>.

[value,ori_pref] = max(odf3)

%%
% 94 times random. Marked in the pole figures, it sits on the strongest
% spot of each of them, which is the check that it is the orientation the
% measurement was about.

plotPDF(odf3,pf.allH,'antipodal','superposition',pf.c);
annotate(ori_pref,'marker','s','MarkerFaceColor','black')

%% Texture Index and Entropy
%
% Both answer "how sharp is this texture?" with a single number. The texture
% index is the mean square of the ODF,
%
% $$ t = \int_{SO(3)} f(R)^2\, dR, $$
%
% which is 1 for the uniform texture and grows without bound as a texture
% sharpens. It is computed as an integral,

t = mean(odf1.*odf1)

%%
% or, faster and more accurately, from the harmonic coefficients by
% <SO3Fun.norm.html |norm|>.

t = norm(odf1)^2

%%
% For the measured ODF the index is far smaller, which says the texture is
% much weaker than the model built from two sharp components.

norm(odf3)^2

%%
% The entropy
%
% $$ H = - \int_{SO(3)} f(R) \ln f(R)\, dR $$
%
% runs the other way: it is 0 for the uniform texture and negative for any
% other, the more so the sharper.

entropy(odf2)

%% Volume Fractions
%
% The most tangible number of all: what fraction of the material lies within
% a given distance of an orientation or of a fibre.
% <SO3Fun.volume.html |volume|> answers both.

volume(odf3, ori_pref, 30*degree) * 100

%%
% 38 percent of the specimen sits within $30^\circ$ of the preferred
% orientation. Around a fibre the same command takes the fibre instead:

volume(odf2, f001_x, 20*degree) * 100

%%
% 95 percent - almost everything, since this ODF *is* that fibre, spread
% with the default halfwidth. Volume fractions are what turn a density into
% a statement about the material, see <ODFTheory.html Theory>.

%% Next
%
% The components a texture is made of, and how to fit them, are
% <ODFComponents.html Components>. Plotting the ODF rather than reducing it
% to numbers is <ODFPlot.html Plotting>.

%#ok<*NASGU>
%#ok<*NOPTS>
