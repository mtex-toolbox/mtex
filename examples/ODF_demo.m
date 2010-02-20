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


%%
% An ODF estimated from diffraction data:
cs = symmetry('-3m',[1.4,1.4,1.5]);
ss = symmetry('triclinic');

fname = {...
  [mtexDataPath '/dubna/Q(10-10)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(10-11)(01-11)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(11-22)_amp.cnv']};
h = {Miller(1,0,-1,0,cs),[Miller(0,1,-1,1,cs),Miller(1,0,-1,1,cs)],Miller(1,1,-2,2,cs)};
c = {1,[0.52 ,1.23],1};

pf = loadPoleFigure(fname,h,cs,ss,'superposition',c,...
  'comment','Dubna Tutorial pole figures');

odf3 = calcODF(pf,'resolution',5*degree,'iter_max',10)


%% Modal Orientations
% The modal orientation of an ODF is the crystallographic prefered
% orientation of the texture. It is characterized as the maximum of the
% ODF. In MTEX it can be computed by the command 
% [[ODF_modalorientation.html,modalorientation]]

%%
% Determine the modalorientation as an
% [[quaternion_index.html,quaternion]]:
center = modalorientation(odf3)


%% Texture Characteristics
%
% Texture characteristics are used for a rough classification of ODF into
% sharp and weak ones. The two most common texture characteristcs are the
% [[ODF_entropy.html,entropy]] and the 
% [[ODF_textureindex.html,texture index]]. 

%%
% Compute the texture index:
textureindex(odf1)                   
%%
% Compute the entropy:
entropy(odf2)


%% Volume Portions
%
% Volume portions describes the relative volume of crystals having a
% certain orientation. The relative volume of crystals having a orientation
% close to a given orientation is computed by the command
% [[ODF_volume.html,volume]] and the relative volume of crystals having a 
% orientation close to a given fibre is computed by the command
% [[ODF_fibrevolume.html,fibrevolume]]

%%
% The relative volume of crystals with missorientation maximum 30 degree
% from the modal orientation:
volume(odf3,modalorientation(odf3),30*degree)  

%%
% The relative volume of crystals with missorientation maximum 20 degree
% from the prefered fibre:
fibrevolume(odf2,Miller(0,0,1),xvector,10*degree)  


%% Fourier Coefficients
% 
% The Fourier coefficients allow for a complete characterization of the
% ODF. The are of particular importance for the calcuation of mean
% macroscopic properties e.g. the second order Fourier coefficients 
% characterize thermal expansion, optical refraction index, and 
% electrical conductivity whereas the fourth order Fourier
% coefficients characterize the elastic properties of the specimen.
% Moreover, the decay of the Fourier coefficients is directly related to
% the smoothness of the ODF. The decay of the Fourier coefficients might
% also hint for the presents of a ghost effect. See 
% [[ghost_demo.html,ghost effect]].

%%
% The Fourier coefficients of order 2:
Fourier(odf2,'order',2)              

%%
% The decay of the Fourier coefficients:
close all;
plotFourier(odf3,'bandwidth',32)

