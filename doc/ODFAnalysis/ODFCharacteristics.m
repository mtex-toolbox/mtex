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

f001_x = fibre(Miller(0,0,1,cs),xvector)

odf2 = fibreODF(f001_x)

%%
% An ODF estimated from diffraction data

mtexdata dubna

odf3 = calcODF(pf,'resolution',5*degree,'zero_Range')


%% Modal Orientations
% The modal orientation of an ODF is the crystallographic preferred
% orientation |ori_pref| of the texture. It is characterized as the maximum
% of the ODF. In MTEX it is returned as the second output argument of the
% command <SO3Fun.max.html |max|>

[~,ori_pref] = max(odf3)

%%
% Lets mark this preferred orientation in the pole figures

plotPDF(odf3,pf.allH,'antipodal','superposition',pf.c);
annotate(ori_pref,'marker','s','MarkerFaceColor','black')

%% Texture Characteristics
%
% Texture characteristics are used for a rough classification of ODFs into
% sharp and weak ones. The two most common texture characteristics are the
% entropy and the texture index. The texture index of an ODF $f$ is defined
% as:
%
% $$ t = \int_{SO(3)} f({R})^2 dR$$
%
% We may either compute this integral using the command <SO3Fun.sum.html
% |sum|> directly by

t = mean(odf1.*odf1)

%%
% or, more efficiently, by the command <SO3Fun.norm.html |norm|>

t = norm(odf1)^2


%%
% The entropy of an ODF $f$ is defined as:
%
% $$ H = - \int_{SO(3)} f({R}) \ln f({R}) dR$$


H = entropy(odf2)


%% Volume Portions
%
% Volume portions describes the relative volume of crystals having a
% certain orientation. The relative volume of crystals having a orientation
% close to a given orientation is computed by the command
% <SO3Fun.volume.html |volume|> and the relative volume of crystals having a
% orientation close to a given fibre is computed by the command
% <SO3Fun.fibreVolume.html |fibreVolume|>

%%
% The relative volume in percent of crystals with missorientation maximum
% 30 degree from the preferred orientation |ori_pref|:

V1 = volume(odf3, ori_pref, 30*degree) * 100

%%
% The relative volume of crystals with missorientation maximum 20 degree
% from the preferred fibre in percent:

V2 = volume(odf2,f001_x,20*degree) * 100

%#ok<*NASGU>
%#ok<*NOPTS>