%% ODF Characteristics
%
%%
%
% Let us first begin with some constructed ODFs to be analyzed below

%%
% A bimodal ODF:
cs = crystalSymmetry('mmm');
odf1 = unimodalODF(orientation.byEuler(0,0,0,cs)) + ...
  unimodalODF(orientation.byEuler(30*degree,0,0,cs))

%%
% A fibre ODF:

odf2 = fibreODF(Miller(0,0,1,cs),xvector)

%%
% An ODF estimated from diffraction data

mtexdata dubna

odf3 = calcODF(pf,'resolution',5*degree,'zero_Range')


%% Modal Orientations
% The modal orientation of an ODF is the crystallographic prefered
% orientation of the texture. It is characterized as the maximum of the
% ODF. In MTEX it can be computed by the command
% <ODF.calcModes.html calcModes>

%%
% Determine the modalorientation as an
% <orientation.orientation.html orientation>:
center = calcModes(odf3)

%%
% Lets mark this prefered orientation in the pole figures

plotPDF(odf3,pf.allH,'antipodal','superposition',pf.c);
annotate(center,'marker','s','MarkerFaceColor','black')

%% Texture Characteristics
%
% Texture characteristics are used for a rough classification of ODF into
% sharp and weak ones. The two most common texture characteristics are the
% <ODF.entropy.html entropy> and the
% <ODF.textureindex.html texture index>.

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
% <ODF.volume.html volume> and the relative volume of crystals having a
% orientation close to a given fibre is computed by the command
% <ODF.fibreVolume.html fibreVolume>

%%
% The relative volume in percent of crystals with missorientation maximum
% 30 degree from the modal orientation:
volume(odf3,calcModes(odf3),30*degree)*100

%%
% The relative volume of crystals with missorientation maximum 20 degree
% from the prefered fibre in percent:
% TODO
%fibreVolume(odf2,Miller(0,0,1),xvector,20*degree) * 100



%% Extract Internal Representation
% The internal representation of the ODF can be addressed by the command

properties(odf3.components{1})

%%
% The properties in this list can be accessed by

odf3.components{1}.center

odf3.components{1}.psi
