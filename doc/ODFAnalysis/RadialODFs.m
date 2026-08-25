%% Radial Basis Functions on SO(3)
%
%%
% The most common model textures are built from *radial* functions: a shape
% that depends only on how far an orientation is from a centre. MTEX
% represents them by the class |@SO3FunRBF|, and three kinds of ODF are of
% this form - the uniform one, a single peak, and a sum of peaks.
%
% What the peak looks like is the <SO3Kernels.html kernel>, treated in
% <ODFShapes.html Unimodal ODF Shapes>.

plottingConvention.default('y↑→x');

%% The Uniform ODF
%
% The uniform ODF
%
% $$f(g) = 1,\quad  g \in SO(3),$$
%
% is everywhere identical to one. In order to define a uniform ODF
% one needs only to specify its crystal and specimen symmetry and to use
% the command <uniformODF.html uniformODF>.

cs = crystalSymmetry('cubic');
ss = specimenSymmetry('orthorhombic');
odf = uniformODF(cs,ss)

%% Unimodal ODFs
%
% A unimodal ODF
%
% $$f(g; x) = \psi (\angle(g,x)),\quad g \in SO(3),$$
%
% is a <SO3Kernels.html radially symmetric function>
% $\psi$ centered at a modal <orientation.orientation.html orientation>,
% $x\in SO(3)$. In order to define a unimodal ODF one needs
%
% * a preferred <orientation.orientation.html orientation> mod1
% * a <SO3Kernels.html kernel> function |psi| defining the shape
% * the <crystalSymmetry.crystalSymmetry.html crystal symmetry>

cs = crystalSymmetry('432');
ori = orientation.byMiller([1,2,2],[2,2,1],cs);
psi = SO3vonMisesFisherKernel('halfwidth',10*degree);
odf1 = unimodalODF(ori,psi)

plotPDF(odf1,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% One orientation, and with it one set of symmetrically equivalent spots per
% pole figure. The kernel may be omitted, in which case MTEX uses the de la
% Vallee Poussin kernel with a halfwidth of $10^\circ$.

%% Multimodal ODFs
%
% A second unimodal ODF, same kernel and symmetry, different orientation.

ori2 = orientation.byMiller([1,1,2],[0,2,1],cs)
odf2 = unimodalODF(ori2,psi)

plotPDF(odf2,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% Adding them gives a multimodal ODF - a sum of kernels centred at several
% orientations.

odf3 = odf1 + odf2

plotPDF(odf3,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% Both sets of spots are there, and each is as strong as it was on its own.
% That is worth watching: a plain sum of two ODFs has mean 2, not 1.

mean(odf3)

%%
% A texture made of two components with equal shares is |0.5*odf1 +
% 0.5*odf2|, whose mean is 1 again and whose weights are volume fractions.
%
% Any number of orientations may be used, with weights of their own -

odf4 = SO3FunRBF.example

plotPDF(odf4,[Miller(1,0,0,odf4.CS),Miller(1,1,0,odf4.CS)],'antipodal')

%%
% and the ODF stays a density with mean 1.

mean(odf4)

%% Next
%
% The kernels that give these peaks their shape are
% <ODFShapes.html Unimodal ODF Shapes>. A peak spread along a curve rather
% than about a point is a <FibreODFs.html Fibre ODF>.

%#ok<*NOPTS>
