%% Radial Basis Functions on SO(3)
%
% In MTEX we describe radial basis functions on the rotation group $SO(3)$
% by the class |@SO3FunRBF|.
%
% This includes the following three types of ODFs.

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
% An unimodal ODF
%
% $$f(g; x) = \psi (\angle(g,x)),\quad g \in SO(3),$$
%
% is specified by a <SO3Kernels.html radial symmetrical function>
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
% For simplicity one can also omit the kernel function. In this case the
% default SO(3) de la Vallee Poussin kernel is chosen with half width of 10 degree.

%% Multimodal ODFs
%
% We define a second unimodal ODF with same <SO3Kernels.html kernel function>
% and same <crystalSymmetry.crystalSymmetry.html crystal symmetry> at an 
% other <orientation.orientation.html orientation>.

ori2 = orientation.byMiller([1,1,2],[0,2,1],cs)
odf2 = unimodalODF(ori2,psi)

plotPDF(odf2,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% By adding this unimodal ODFs we get an so called multimodal ODF, which by
% construction is the sum of the <SO3Kernels.html radial symmetrical function>
% $\psi$ centered at some <orientation.orientation.html orientations>. 

odf3 = odf1 + odf2

plotPDF(odf3,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% Its also possible to define an multimodal ODF by more than two 
% <orientation.orientation.html orientations>, for example

odf4 = SO3FunRBF.example

plotPDF(odf4,[Miller(1,0,0,odf4.CS),Miller(1,1,0,odf4.CS)],'antipodal')

