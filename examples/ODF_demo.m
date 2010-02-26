%% Orientation Density Functions
%
%% Abstract
% This example demonstrates the most important MTEX tools for analysing
% ODFs. All described commands can be applied to model ODFs constructed via
% [[uniformODF.html, uniformODF]], [[unimodalODF.html, unimodalODF]],
% or [[fibreODF.html, fibreODF]] and to all estimated ODF calculated
% from [[PoleFigure_calcODF.html, pole figures]] or
% [[EBSD_calcODF.html, EBSD data]].
%
%
%% Defining Model ODFs
%
% *Unimodal ODFs*

SS  = symmetry('orthorhombic');
CS  = symmetry('cubic');
o   = orientation('brass',CS,SS);
psi = kernel('von Mises Fisher',...
             'halfwidth',20*degree);

odf1 = unimodalODF(o,CS,SS,psi)

%%
% *Fibre ODFs*

SS = symmetry('triclinic');
CS = symmetry('hexagonal');
h = Miller(1,0,0,CS);
r = xvector;
psi = kernel('Abel Poisson',...
             'halfwidth',18*degree);

odf2 = fibreODF(h,r,CS,SS,psi)

%%
% *uniform ODFs*

odf3 = uniformODF(CS,SS)

%%
% *FourierODF*


%%
% *Bingham ODFs*

Lambda = [-10,-10,10,10]
A = quaternion(eye(4))
odf = BinghamODF(Lambda,A,CS,SS)

plotipdf(odf,xvector)
plotpdf(odf,Miller(1,0,0))

%%
% *ODF Arithmetics*

0.2*odf1 + 0.3*odf2 + 0.5*odf3

rot = rotation('axis',yvector,'angle',90*degree);
odf = rotate(odf,rot)
plotpdf(odf,Miller(1,0,0))

%% Working with ODFs

% *Texture Characteristics+

calcerror(odf2,odf3,'L1')      % difference between ODFs

center = modalorientation(odf) % the modal orientation
mean(odf)                      % the mean orientation
max(odf)

volume(odf,center,5*degree)    % the volume of a ball
fibrevolume(odf2,h,r,5*degree) % the volume of a fibre

textureindex(odf)         % the texture index
entropy(odf)              % the entropy
Fourier(odf2,3)           % the C-coefficients


%% Plotting ODFs
% *Plotting (Inverse) Pole Figures*

close all
plotpdf(odf,Miller(0,1,0),'antipodal')
plotipdf(odf,[xvector,zvector])

%%
% *Plotting an ODF*

close all
plot(santafee,'alpha','sections',6,'projection','plain','gray','contourf')

%% Exercises
%
% 2)
%
% a) Construct a cubic unimodal ODF with mod at [0 0 1](3 1 0). (Miller
% indice). What is its modal orientation in Euler angles?

cs = symmetry('cubic');
ss = symmetry('triclinic');
ori = orientation('Miller',[0 0 1],[3 1 0],cs,ss);
odf = unimodalODF(ori,cs,ss);

%%
% b) Plot some pole figures. Are there pole figures with and without
% antipodal symmetry? What about the inverse pole figures?

plotpdf(odf,[Miller(1,0,0),Miller(2,3,1)])

%%

close all;plotpdf(odf,[Miller(1,0,0),Miller(2,3,1)],'antipodal')

%%

close all;plotipdf(odf,vector3d(1,1,3))

%%
% c) Plot the ODF in sigma and phi2 - sections. How many mods do
% you observe?

close all;plotodf(odf,'sections',6)

%%
% d) Compute the volume of the ODF that is within a distance of 10 degree of
% the mod. Compare to an the uniform ODF.

volume(odf,ori,10*degree)
volume(uniformODF(cs,ss),ori,10*degree)

%%
% e) Construct a trigonal ODF that consists of two fibres at h1 =
% (0,0,0,1), r1 = (0,1,0), h2 = (1,0,-1,0), r2 = (1,0,0). Do the two fibres intersect?

cs = symmetry('trigonal');
odf = 0.5 * fibreODF(Miller(0,0,0,1),yvector,cs,ss) + ...
      0.5 * fibreODF(Miller(1,0,-1,0),xvector,cs,ss)

%%
% f) What is the modal orientation of the ODF?

mod = modalorientation(odf)


%%
% g) Plot the ODF in sigma and phi2 - sections. How many fibre do
% you observe?

close all;plot(odf,'sections',6,'gray')
annotate(mod,'MarkerColor','r','Marker','s')

%%
plot(odf,'phi2','sections',6)

%%
% h) Compute the texture index of the ODF.

textureindex(odf)
