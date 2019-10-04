%% Unimodal ODFs
%
% An unimodal ODF
%
% $$f(g; x) = \psi (\angle(g,x)),\quad g \in SO(3),$$
%
% is specified by a <kernel_index.html radially symmetrial function> $\psi$
% centered at a modal <orientation_index.html orientation>, $x\in SO(3)$
% and. In order to define a unimodal ODF one needs
%
% * a preferred <orientation_index.html orientation> mod1
% * a <kernel_index.html kernel> function |psi| defining the shape
% * the crystal and specimen <symmetry_index.html symmetry>

cs = crystalSymmetry('432');
ori = orientation.byMiller([1,2,2],[2,2,1],cs);
psi = vonMisesFisherKernel('halfwidth',10*degree);
odf = unimodalODF(ori,psi)

plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% For simplicity one can also omit the kernel function. In this case the
% default de la Vallee Poussin kernel is chosen with half width of 10 degree.


