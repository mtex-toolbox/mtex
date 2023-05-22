%% Martensite Variants
%
%%
% In this section we discuss the austenite (fcc) to ferrite (bcc) phase
% transformation on the example of an EBSD data set collected on a
% plessitic microstructure of the Emsland iron meteorite. Plessite is the
% greek description for filling iron and occurs as remaining volumes
% between the already transformed kamacite (bcc in meteorites) rims.
% Plessite regions are commonly surrounded by a very thin taenite (fcc)
% ribbons. The filling iron contains as major phases again bcc and fcc,
% where the orientation of fcc practically always indicates the orientation
% of the formerly huge fcc grain in the planetary body which can easily
% reach the dimension of meters.

plotx2east

% import the ebsd data
mtexdata emsland

% extract crystal symmetries
cs_bcc = ebsd('Fe').CS;
cs_aus = ebsd('Aus').CS;

% recover grains
ebsd = ebsd('indexed');

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
ebsd(grains(grains.grainSize<=2)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);

grains = smooth(grains,4);

%%
% The following lines plot bcc according to the crystallographic
% description of the selected reference direction (IPF coloring), whereas
% austeniteis displayed as phase in blue.

plot(ebsd('Fe'),ebsd('Fe').orientations)
hold on
plot(grains.boundary,'lineWidth',2,'lineColor','gray')
plot(grains('Aus'),'FaceColor','blue','edgeColor','b','lineWidth',1,'DisplayName','Austenite')
hold off

%%
% As expected, we recognize very small remaining fcc grains. This
% high-temperatur phase is stabilized by the increasing nickel content
% during transformation. The low-temperature bcc phase can solve in maximum
% only 6\% nickel so that fcc has to assimilate the excess nickel. Size and
% amount of fcc is therefore and indication of the overall nickel content.
% Considering only the parent fcc phase and plotting the orientations into
% an axis angle plot

plot(ebsd('Aus').orientations,'axisAngle')

%%
% we recognize the uniform orientation of all fcc grains. Deviations are
% assumed to be the result of deformations during high-speed collisions in
% asteroitic belt. We can get this parent grain orientation by taking the
% <orientation.mean.html |mean|> and compute the fit by the command
% <orientation.std.html |std|>

parenOri = mean(ebsd('Aus').orientations)

fit = std(ebsd('Aus').orientations) ./ degree

%%
% Next we display the bcc orientations (blue dots) in pole figures, and
% additionally we plot on top of them the parent taenite orientation (red
% dots).

childOri = grains('Fe').meanOrientation;

h_bcc = Miller({1,0,0},{1,1,0},{1,1,1},cs_bcc);
h_fcc = Miller({1,0,0},{1,1,0},{1,1,1},cs_aus);

plotPDF(childOri,h_bcc,'MarkerSize',5,'MarkerFaceAlpha',0.05,'MarkerEdgeAlpha',0.1,'points',500);

nextAxis(1)
hold on
plot(parenOri * h_fcc(1).symmetrise ,'MarkerFaceColor','r')
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parenOri * h_fcc(3).symmetrise ,'MarkerFaceColor','r')
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parenOri * h_fcc(2).symmetrise ,'MarkerFaceColor','r')
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off

drawNow(gcm)

%%
% The partial coincidence of bcc and fcc poles suggests an existing of a
% crystallographic orientation relationship between both phases. The
% Kurdjumov-Sachs (KS) orientation relationship model assumes a transition
% of one of the {111}-fcc into one of the {110}-bcc planes. Moreover,
% within these planes one of the <110> directions of fcc is assumed to
% remain parallel to one of the <111> directions of the formed bcc. Since
% for cubic crystals identically indexed (hkl) and [uvw] generate the same
% directions, the derived pole figures can be used for both, the evaluation
% of directions as well as lattice plane normals.
%
% Although we could alternatively use the MTEX command
% |orientation.KurdjumovSachs(cs_aus,cs_bcc)|, let us define the
% orientation relationship explicitely:

KS = orientation.map(Miller(1,1,1,cs_aus),Miller(0,1,1,cs_bcc),...
      Miller(-1,0,1,cs_aus),Miller(-1,-1,1,cs_bcc))

plotPDF(variants(KS,parenOri),'add2all','MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',2)

%%
% In order to quantify the match between the Kurdjumov-Sachs model and the
% actual orientation relationship in the specific plessitic area, we can
% compute as simplest indicator the mean angular deviation between all
% parent-to-child misorientaitons and the KS model

% Each parent-to-child misorientations can be calculated by
mori = inv(childOri) * parenOri;

% whereas the mean angular deviation (output in degree) can be computed by the command
mean(angle(mori, KS)) ./ degree

%fit = sqrt(mean(min(angle_outer(childOri,variants(KS,parenOri)),[],2).^2))./degree


%% Estimating the parent to child orientation relationship
%
% We may have asked ourselfs whether there is an orientation relationship
% that better matches the measured misorientations than proposed by the KS
% model. A canocial candidate would be the <orientation.mean.html |mean|>
% of all misorientations.

% The mean of all measured parent-to-child misorientations
p2cMean = mean(mori,'robust')

plotPDF(childOri,h_bcc,'MarkerSize',5,'MarkerFaceAlpha',0.05,'MarkerEdgeAlpha',0.1,'points',500);
hold on
plotPDF(variants(p2cMean,parenOri),'add2all','MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',2)
hold off

% mean angular deviation in degree
mean(angle(mori, p2cMean)) ./ degree

%%
% Here we have made use of our comfortable situation to know the parent
% orientation. If the parent orientation is unknown we may still estimate
% the parent to child orientation relationship soleley from the child to
% child misorientations by the algorithm by Tuomo Nyyssönen and implemented
% in the function <calcParent2Child.html |calcParent2Child|>. This
% iterative algorithms needs as a starting point some orientation relation
% ship no too far from the actual one. Here we use the Nishiyama Wassermann
% orientation relation ship.

% define Nishiyama Wassermann
NW = orientation.NishiyamaWassermann(cs_aus,cs_bcc)

% extract all child to child misorientations 
grainPairs = neighbors(grains('Fe'));
ori = grains(grainPairs).meanOrientation;

% estimate a parent to child orientation relationship
p2cIter = calcParent2Child(ori,NW)

% the mean angular deviation
mean(angle(mori,p2cIter)) ./degree

%%
% We observe that the parent to child orientation relationship computed
% solely from the child to child misorientations fits the actual
% orientation relationship equaly well. 
%
%% Classification of child variants by variant Ids
%
% Once we have determined parent orientations and a parent to child
% orientation relationship, we may proceed further by classifying the child
% orientations into different variants.
%
% A variant refers to a specific orientation or crystallographic arrangement of 
% the child martensite phase within the context of the original parent orientation.
% Depending on the operative orientation relationship and parent-child crystal 
% symmetries, a single parent phase orientation results in multiple child phase 
% orientations (i.e.- variants). The variant Id is a convinient way to label or 
% identify a specific variant within the child martensitic microstructure.
%
% Child variant Ids are computed by the command
% <calcVariantId.html |calcVariantId|>.

% compute for each child orientation a variantId
[variantId, packetId, bainId] = calcVariantId(parenOri,childOri,p2cIter,'morito');

% colorize the orientations according to the variantID
color = ind2color(variantId,'ordered');
plotPDF(childOri,color,h_bcc,'MarkerSize',5);

%%
% While it is very hard to distinguish the different variants in the pole
% figure plots it becomes more clear in an axis angle plot

plot(childOri,color,'axisAngle')


%% Classification of child variants by crystallographic packet Ids
%
% A more important classification is the seperation of the
% variants into their various crystallographic packets. 
%
% A crystallographic packet Id is used to identify a packet of variants
% with the same habit plane (i.e. - the interfacial plane between the
% parent and child crystal lattices along which the atomic rearrangements
% occur during martensitic transformation).
%
% Within a crystallographic packet, the individual variants are related to
% each other through specific symmetries. The crystallographic packet Id is
% a means of identifying and distinguishing a specific packet of variants
% that share the same habit plane and exhibit related crystallographic
% orientations.

color = ind2color(packetId);
plotPDF(childOri,color,h_bcc,'MarkerSize',5,'points',1000);

nextAxis(1)
hold on
opt = {'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3};
plot(parenOri * h_fcc(1).symmetrise ,opt{:})
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parenOri * h_fcc(3).symmetrise ,opt{:})
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parenOri * h_fcc(2).symmetrise ,opt{:})
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off

drawNow(gcm)

%%
% As we can see from the above pole figures the red, blue, orange and green
% orientations are distinguished by which of the symmetrically equivalent
% (111) austenite axes is aligned to the (110) martensite axis.
%%
% We may also use the packet Id color to distinguish different martensite
% packets in the EBSD map.

plot(grains('Fe'),color)


%% Classification of child variants by Bain group Ids
%
% Another important classification is the seperation of the
% variants into their various Bain groups. 
%
% The concept of Bain groups is based on the Bain notation.The latter provides 
% a concise system of representing the transformation path and the geometric
% correspondence between the crystal structures of the parent austenite and 
% child martensite phases. Each Bain group is labeled with a unique Bain 
% group Id, which represents a distinct combination of orientation relationships 
% between parent and child phases. 
% Bain group Ids serve as a convenient identifier to categorize, classify and 
% differentiate the various transformation paths that may occur during martensitic 
% transformation based on their crystallographic characteristics.

color = ind2color(bainId);
plotPDF(childOri,color,h_bcc,'MarkerSize',5,'points',1000);

nextAxis(1)
hold on
opt = {'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3};
plot(parenOri * h_fcc(1).symmetrise ,opt{:})
xlabel('\((100)\)','Color','red','Interpreter','latex')

nextAxis(2)
plot(parenOri * h_fcc(3).symmetrise ,opt{:})
xlabel('\((111)\)','Color','red','Interpreter','latex')

nextAxis(3)
plot(parenOri * h_fcc(2).symmetrise ,opt{:})
xlabel('\((110)\)','Color','red','Interpreter','latex')
hold off

drawNow(gcm)

%%
% As we can see from the above pole figures the red, blue, and orange
% orientations are distinguished by which of the symmetrically equivalent
% (100) austenite axes is aligned to the (100) martensite axis.
%%
% Similarly, we may also use the Bain group Id color to distinguish different 
% martensite Bain groups in the EBSD map.

plot(grains('Fe'),color)