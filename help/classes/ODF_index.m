%% The Class ODF
% class representing an Orientation Density Function
% 
%% Description
%
% An object of the class @ODF represents an *Orientation Density Function*,
% i.e. a function on SO(3). It is defined as a superposition of radialy
% symmtric, fibre symmetric and uniform components. You can define ODFs
% directly as model ODFs or recalcalculate them from pole figure data. It
% exists methods to calculate the various texture characteristics as the
% entropy, the texture index, the Fourier coefficients or the volume
% percentage with a certain orientation.
%
%% Defining ODFs
%
% A *unimodal ODF* is defined by the following characteristics:
%
%   cs  - crystal [[symmetry_index.html,symmetry]]
%   ss  - specimen [[symmetry_index.html,symmetry]]
%   g   - modal orientation ([[quaternion_index.html,quaternion]])
%   psi - [[kernel_index.html,kernel]] function
%
% using the command [[uniformODF.html,uniformODF]]
cs   = symmetry('orthorhombic'); % crystal symmetry
ss   = symmetry('tricline');     % specimen symmetry
g    = Miller2quat([1,0,0],[0,1,1]);
psi  = kernel('de la Vallee Poussin','halfwidth',10*degree);
uodf = unimodalODF(g,cs,ss,psi)
%%
% For a *fibre symmetric ODF* a crystal direction and a specimen direction
% are needed instead of the modal orientation, i.e.
%
%   h - [[Miller_index.html,Miller]] crystal direction
%   r - [[vector3d_index.html,vector3d]] specimen direction
%
% the corresponding method is [[fibreODF.html,fibreODF]]
h    = Miller(1,0,0,cs);
r    = xvector;
fodf = fibreODF(h,r,cs,ss,psi)


%% Modifying ODFs
%
% You can rotate a ODF by an arbitrary roation using the method 
% [[ODF_rotate.html,rotate]]. Moreover you can use the operators "+", "*" do 
% superpose different ODFs. A valid expression is for example

odf = 0.2*rotate(uodf,axis2quat(zvector,90*degree)) + ...
      0.7*fodf + 0.1*uniformODF(cs,ss) 

%% Calculating texture characteristics of ODFs
%
% For any object of class @ODF you can calculate its 
% [[ODF_entropy.html,entropy]], its [[ODF_textureindex.html,textureindex]]
% or the [[ODF_volume.html,volume]] ratio corresponging to a specific
% orientation. Additional functions are 
% [[ODF_min.html,min]],
% [[ODF_max.html,max]],
% [[ODF_hist.html,hist]],
% [[ODF_mean.html,mean]],
% [[ODF_modalorientation.html,modalorientation]],
% [[ODF_std.html,std]].
% Valid commands are e.g.

entropy(uodf);
textureindex(fodf);
volume(odf,g,5*degree);

    
%% Plotting ODFs
%
% There are several methods to visualize a ODF. First you can plot the ODF
% directly with respect to various sections. See [[ODF_plotodf.html,plotodf]].
% Furhermore you can plot pole figures or inverse pole figures using the
% commands [[ODF_plotpdf.html,plotpdf]] and [[ODF_plotipdf.html,plotipdf]].

figure('position',[100 100 700 300])
plot(odf,'sections',10,'silent')   % plot odf
%%
plotpdf(odf,Miller(0,0,1),'reduced')   % plot pole figure
%%
plotipdf(odf,xvector)        % plot inverse pole figure

