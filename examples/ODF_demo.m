%% Orientation Density Functions
%
%% Abstract
% This example demonstrates the most important MTEX tools for analysing
% ODFs. All described commands can be applied to model ODFs constructed via
% <uniformODF.html uniformODF>, <unimodalODF.html unimodalODF>,
% or <fibreODF.html fibreODF> and to all estimated ODF calculated
% from <PoleFigure_calcODF.html pole figures< or 
% <EBSD_calcODF.html EBSD data>.
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

calcerror(odf2,odf3,'L1')   % difference between ODFs

center = modalorientation(odf) % the modal orientation
mean(odf)             % the mean orientation
max(odf)

volume(odf,center,5*degree)   % the volume of a ball
fibrevolume(odf2,h,r,5*degree) % the volume of a fibre

textureindex(odf)         % the texture index
entropy(odf)              % the entropy
fourier(odf2,3)            % the C-coefficients


% *Plotting (Inverse) Pole Figures*

plotpdf(odf,Miller(0,1,0),'antipodal')
plotipdf(odf,[xvector,zvector])


% *Plotting an ODF*

plot(santafee,'alpha','sections',18,'projection','plain','gray','contourf')

%% Exercises
%
% # Construct a cubic unimodal ODF with mod at [0 0 1](3 1 0).
% # What is its modal orientation in Euler angles?
% # Plot some pole figures. Are there pole figures that with and without
% antipodal symmetry? What about the inverse pole figures?
% # Plot the ODF in sigma and phi2 - sections. How many mods do
% you observe? 
% # Compute the volume of the ODF that is within a distance of 10 degree of
% the mod. Compare to an the uniform ODF.
% # Construct a trigonal ODF that consists of two fibres at h1 =
% (0,0,0,1), r1 = (0,1,0), h2 = (1,0,-1,0), r2 = (1,0,0).
% # Do the two fibres intersect?
% # What is the modal orientation of the ODF?
% # Plot the ODF in sigma and phi2 - sections. How many fibre do
% you observe?
% # Compute the texture index of the ODF.
