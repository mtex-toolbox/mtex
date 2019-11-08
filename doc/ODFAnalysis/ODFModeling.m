%% ODF Modeling
%
%%
%
% MTEX provides a very simple way to define model ODFs. Generally, there
% are five different ODF types in MTEX:
%
% * <uniformODF.html uniform ODFs>
% * <UnimodalODFs.html unimodal ODFs>
% * <FibreODFs.html fibre ODFs>
% * <BinghamODFs Bingham ODFs>
% * <HarmonicODFs ODFs given by harmonic series expansion>
%
% The central idea is that MTEX allows you to calculate mixture models, by
% adding and subtracting arbitrary ODFs. Model ODFs may be used as
% references for ODFs estimated from pole figure data or EBSD data and are
% instrumental for simulating texture evolutions.
%
%% The Uniform ODF
%
% The most simplest case of a model ODF is the uniform ODF
%
% $$f(g) = 1,\quad  g \in SO(3),$$
%
% which is everywhere identical to one. In order to define a uniform ODF
% one needs only to specify its crystal and specimen symmetry and to use
% the command <uniformODF.html uniformODF>.

cs = crystalSymmetry('cubic');
ss = specimenSymmetry('orthorhombic');
odf = uniformODF(cs,ss)

%% Combining model ODFs
% All the above can be arbitrarily rotated and combined. For instance, the
% classical Santafe example can be defined by commands

cs = crystalSymmetry('cubic');
ss = specimenSymmetry('orthorhombic');

psi = vonMisesFisherKernel('halfwidth',10*degree);
mod1 = orientation.byMiller([1,2,2],[2,2,1],cs,ss);

odf =  0.73 * uniformODF(cs,ss) + 0.27 * unimodalODF(mod1,psi)

close all
plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')



