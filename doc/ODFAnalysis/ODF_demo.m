%% Orientation Density Functions
% This example demonstrates the most important MTEX tools for analysing
% ODFs.
%%
% All described commands can be applied to model ODFs constructed via
% <uniformODF.html uniformODF>, <unimodalODF.html unimodalODF>,
% or <fibreODF.html fibreODF> and to all estimated ODF calculated
% from <PoleFigure_calcODF.html pole figures> or
% <EBSD_calcODF.html EBSD data>.
%
%

%% Open in Editor
%

%% Defining Model ODFs
%
% *Unimodal ODFs*

SS  = specimenSymmetry('orthorhombic');
CS  = crystalSymmetry('cubic');
o   = orientation('brass',CS,SS);
psi = vonMisesFisherKernel('halfwidth',20*degree);

odf1 = unimodalODF(o,CS,SS,psi)

%%
% *Fibre ODFs*

CS = crystalSymmetry('hexagonal');
h = Miller(1,0,0,CS);
r = xvector;
psi = AbelPoissonKernel('halfwidth',18*degree);

odf2 = fibreODF(h,r,psi)

%%
% *uniform ODFs*

odf3 = uniformODF(CS)

%%
% *FourierODF*


%%
% *Bingham ODFs*

Lambda = [-10,-10,10,10]
A = quaternion(eye(4))
odf = BinghamODF(Lambda,A,CS)

plotIPDF(odf,xvector)
plotPDF(odf,Miller(1,0,0,CS))

%%
% *ODF Arithmetics*

0.3*odf2 + 0.7*odf3

rot = rotation.byAxisAngle(yvector,90*degree);
odf = rotate(odf,rot)
plotPDF(odf,Miller(1,0,0,CS))

%% Working with ODFs

% *Texture Characteristics+

calcError(odf2,odf3,'L1')      % difference between ODFs

[maxODF,centerODF] = max(odf)  % the modal orientation
mean(odf)                      % the mean orientation
max(odf)

volume(odf,centerODF,5*degree) % the volume of a ball
fibreVolume(odf2,h,r,5*degree) % the volume of a fibre

textureindex(odf)              % the texture index
entropy(odf)                   % the entropy
f_hat = calcFourier(odf2,16);  % the C-coefficients up to order 16


%% Plotting ODFs
% *Plotting (Inverse) Pole Figures*

close all
plotPDF(odf,Miller(0,1,0,CS),'antipodal')
plotIPDF(odf,[xvector,zvector])

%%
% *Plotting an ODF*

close all
plot(SantaFe,'alpha','sections',6,'projection','plain','contourf')
mtexColorMap white2black

%% Exercises
%
% 2)
%
% a) Construct a cubic unimodal ODF with mod at [0 0 1](3 1 0). (Miller
% indice). What is its modal orientation in Euler angles?

CS = crystalSymmetry('cubic');
ori = orientation.byMiller([0 0 1],[3 1 0],CS);
odf = unimodalODF(ori);

%%
% b) Plot some pole figures. Are there pole figures with and without
% antipodal symmetry? What about the inverse pole figures?

plotPDF(odf,[Miller(1,0,0,CS),Miller(2,3,1,CS)])

%%

close all;plotPDF(odf,[Miller(1,0,0,CS),Miller(2,3,1,CS)],'antipodal')

%%

close all;plotIPDF(odf,vector3d(1,1,3))

%%
% c) Plot the ODF in sigma and phi2 - sections. How many mods do
% you observe?

close all; plot(odf,'sections',6)

%%
% d) Compute the volume of the ODF that is within a distance of 10 degree of
% the mod. Compare to an the uniform ODF.

volume(odf,ori,10*degree)
volume(uniformODF(CS,SS),ori,10*degree)

%%
% e) Construct a trigonal ODF that consists of two fibres at h1 =
% (0,0,0,1), r1 = (0,1,0), h2 = (1,0,-1,0), r2 = (1,0,0). Do the two fibres intersect?

cs = crystalSymmetry('trigonal');
odf = 0.5 * fibreODF(Miller(0,0,0,1,cs),yvector) + ...
      0.5 * fibreODF(Miller(1,0,-1,0,cs),xvector)

%%
% f) What is the modal orientation of the ODF?

mod = calcModes(odf)


%%
% g) Plot the ODF in sigma and phi2 - sections. How many fibre do
% you observe?

close all;plot(odf,'sections',6)
mtexColorMap white2black
annotate(mod,'MarkerColor','r','Marker','s')

%%
plot(odf,'phi2','sections',6)

%%
% h) Compute the texture index of the ODF.

textureindex(odf)
