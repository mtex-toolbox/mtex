%% Model ODFs
%
%% Open in Editor
%
%% Contents
%
%% Abstract
% MTEX allows to create a wide range of model ODFs including 
% [[uniformODF.html,uniformODFs]], [[unimodalODF.html,unimodalODFs]],
% [[fibreODF.html,fibreODFs]] and any superposition of those ODF.
% These ODFs can be used to 
% <MTEX_PoleFigureSimulation_demo.html simulate PoleFigures> or to 
% <MTEX_EBSDSimulation_demo.html simulate EBSD data>.

%% The Uniform ODF
%
% The most simplest case of a model ODF is the uniform ODF which is
% everywhere identical to one.
% In order to define a uniform ODF one needs only to specify its crystal
% and specimen symmetry and to use the command 
% <uniformODF.html uniformODF>.

cs = symmetry('cubic');
ss = symmetry('orthorhombic');
odf = uniformODF(cs,ss)


%% Unimodal ODFs
%
% In order to define a unimodal ODF one needs 
%
% * a preferred orientation *mod1*
% * a kernel function *psi* defining the shape
% * the crystal and specimen symmetry

mod1 = orientation('Miller',[1,2,2],[2,2,1],cs,ss);
psi = kernel('von Mises Fisher','HALFWIDTH',10*degree);
odf = unimodalODF(mod1,cs,ss,psi)

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0)],'antipodal',...
  'position',[100   100   600   170])

%%
% For simplicity one can also ommit the kernel function. In this case the
% default de la Vallee Poussin kernel is choosen with halfwidth of 10 degree.


%% Fibre ODFs
%
% In order to define a fibre ODF one needs 
%
% * a crystal direction *h0*
% * a specimen direction *r0*
% * a kernel function *psi* defining the shape
% * the crystal and specimen symmetry

h0 = Miller(0,0,1);
r0 = xvector;
odf = fibreODF(h0,r0,cs,ss,psi)

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0)],'antipodal')

%% ODFs given by Fourier coefficients
%
% In order to define a ODF by it *Fourier coefficients* the Fourier
% coefficients *C* has to be give as a literaly ordered, complex valued
% vector of the form 
%
% $$ C = [C_0,C_1^{-1-1},\ldots,C_1^{11},C_2^{-2-2},\ldots,C_L^{LL}] $$
%
% where $l=0,\ldots,L$ denotes the order of the Fourier coefficients.

cs   = symmetry('triclinic');    % crystal symmetry
ss   = symmetry('triclinic');    % specimen symmetry
C = [1;reshape(eye(3),[],1);reshape(eye(5),[],1)]; % Fourier coefficients
odf = FourierODF(C,cs,ss)

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0)],'antipodal')

%% Bingham distributed ODFs
%
% The Bingham dsitribution is a parametric ODF distribution that allows for
% many different kinds of ODF, e.g.
%
% * unimodal ODFs
% * fibre ODF
% * spherical ODFs
%
% A Bingham distribution is characterized by
%
% * four orientations ([quaternion_index.html,quaternions])
% * four values lambda
%

cs = symmetry('-3m');
ss = symmetry('-1');

%%
% A Bingham unimodal ODF

odf = BinghamODF([-10,-10,-10,10],quaternion(eye(4)),cs,ss)

plot(odf,'sections',6,'silent','position',[100 100 600 300])

%% 
% A Bingham fibre ODF

odf = BinghamODF([-10,-10,10,10],quaternion(eye(4)),cs,ss)

plot(odf,'sections',6,'silent')

%% 
% A Bingham spherical ODF

odf = BinghamODF([-10,10,10,10],quaternion(eye(4)),cs,ss)

plot(odf,'sections',6,'silent');


%%
%% Combining MODEL ODFs
%
% All the above can be arbitrily rotated and combinend. For instance, the
% classical Santafe example can be defined by commands

cs = symmetry('cubic');
ss = symmetry('orthorhombic');

psi = kernel('von Mises Fisher','HALFWIDTH',10*degree);
mod1 = orientation('Miller',[1,2,2],[2,2,1],cs,ss);

odf =  0.73 * uniformODF(cs,ss,'comment','the Santafee-sample ODF') ...
  + 0.27 * unimodalODF(mod1,cs,ss,psi)

plotpdf(odf,[Miller(1,0,0),Miller(1,1,0)],'antipodal',...
  'position',[100   100   600   170])
