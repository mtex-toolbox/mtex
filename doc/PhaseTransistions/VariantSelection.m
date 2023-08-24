%% Transformation Texture
%
% During phase transformation or twinning the orientation of a crystal
% rapidly flips from an initial state |oriA| into a transformed state
% |oriB|. This relationship between the initial and transformed state can
% be described by an orientation relationsship |OR|. To make the situation
% more precise, we consider the phase transformation from austenite to
% ferrite via the Nishiyama Wassermann orientation relationship

% parent and child crystal symmetry
csP = crystalSymmetry('432','mineral','Austenite');
csC = crystalSymmetry('432','mineral','Ferrite');

% the orientation relationship
p2c = orientation.NishiyamaWassermann(csP,csC);

%%
% Now an arbitrary  Austenite orientation 

oriA = orientation.rand(csP)

%%
% is transformed in one of the following Ferrite orientations

oriB = variants(p2c,oriA)

%%
% These 12 Ferrite orientations are called variants of the orientation
% relationship. Lets visualize them in a pole figure plot

hC = Miller({1,1,1},{1,1,0},csC);
hP = Miller({1,1,0},{1,0,0},csP);

% plot the child variants
plotPDF(oriB,hC,'MarkerSize',5,'markerColor','black','figSize','medium');

% and on top the parent orientation
opt = {'MarkerFaceColor','none','MarkerEdgeColor','darkred','linewidth',3};
for k = 1:2
  nextAxis(k)
  hold on 
  plot(oriA * hP(k).symmetrise ,opt{:})
  xlabel(char(hP(k),'latex'),'Color','red','Interpreter','latex')
  hold off
end
drawNow(gcm)

%%
% In case we have multiple parent orientations following some initial
% orientation distribution function |odf|

% define a model ODF
odfA = unimodalODF(oriA,'halfwidth',5*degree)

plotPDF(odfA,hP,'figSize','medium')
mtexColorbar

%%
% We can draw some random orientations according this model ODF and apply
% the same commands |variants| to compute all transfomed orientations in
% one step

% number of discrete orientations
n = 10000;
oriASim = odfA.discreteSample(n)

% transform the orientations
oriBSim = variants(p2c,oriASim)

% show the result
plotPDF(oriBSim,hC,'contourf','figSize','medium');
mtexColorbar

%%
% An alternative and better approach is to directly use |odfA| as an input
% to the function <orientation.variants.html |variants|>. In this case the
% output is the orientation distribution function of the transformed
% material

% compute the child ODF
odfB = variants(p2c,odfA)

% plot
plotPDF(odfB,hC,'contourf','figSize','medium');
mtexColorbar

%%
% We observe that the transformed ODF computed by the latter approach is
% sharper and shows more details when compared with the ODF computed from
% discrete orientations. We may quantify this difference by computing the
% texture index of both ODFs

% texture index of the transformed ODF computed from discrete orientations
odfBSim = calcDensity(oriBSim)
norm(odfBSim).^2

%%

% texture index of the directly computed transformed ODF 
norm(odfB).^2


%% the discrete route

% draw random parent orientations
parentOri = odfP.discreteSample(500000);

% compute child orientations
childOri = parentOri * inv(p2c);

% compute child ODF
odfC_discrete = calcDensity(childOri,'halfwidth',5*degree)

% plot
plotPDF(childOri,hC,'MarkerSize',5,'points',1000,'contourf');

%% the continous route

% compute the child ODF
odfC = transformODF(odfP,p2c)

% plot
plotPDF(odfC,hC,'MarkerSize',5,'points',1000,'contourf');



%%
figure(1)
plot(odfC_discrete)
figure(2)
plot(odfC)



%%


%color = ind2color(packetId);
plotPDF(childOri,hC,'MarkerSize',5,'points',1000);

nextAxis(1)
hold on
opt = {'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3};
plot(parentOri * hP(1).symmetrise ,opt{:})
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parentOri * hP(3).symmetrise ,opt{:})
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parentOri * hP(2).symmetrise ,opt{:})
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off

drawNow(gcm)

%%
odf = unimodalODF(csP,'halfwidth',5*degree)
p2c = orientation.NishiyamaWassermann(csP,csC);
vDistri = zeros(length(p2c.variants),1);
vDistri(1) = 1;
vDistri(2) = 1;
vDistri(3) = 1;
vDistri(4) = 1;
%vDistri = ones(length(p2c.variants),1);
vDistri = vDistri ./ sum(vDistri);
odfT = SO3FunHandle(@(ori) fun(ori,odf,p2c,vDistri));
%profile on
odfT = SO3FunHarmonic(odfT)
%profile viewer
%%

plotPDF(odfT,hC,'antipodal')

%%

for k = 1:12
  vDistri = zeros(length(p2c.variants),1);
  vDistri(k) = 1;
  odfT = SO3FunHandle(@(ori) fun(ori,odf,p2c,vDistri));
  odfV(k) = SO3FunHarmonic(odfT)
end

%%


cs = crystalSymmetry('622');

mori = orientation.map(Miller(1,1,-2,0,cs),Miller(2,-1,-1,0,cs),...
  Miller(-1,0,1,1,cs),Miller(-1,1,0,1,cs))

mori.angle('max')./degree
mori.axis('max')

% deformation tensor
% --> ??



% 1) initial ODF
% 2) strain + twin system -> transformation texture
% 3) check this with correlation
% 4) two OR -> transformation texture -> fit variant selection
% 5) check this with correlation -> error analysis 

% questions:
% 1) is variant selection correlated with strain?
% 2) 
% 3) 



%%

%odf = fibreODF(fibre.rand(p2c.CS))

oR = fundamentalRegion(p2c.CS);


ori = oR.V(2)

odf = unimodalODF(orientation.rand(p2c.CS))




%%

p2c = orientation.KurdjumovSachs(csP,csC);

vSel = zeros(1,24);
%vSel(1:6) = 1;
vSel = [1 0 0 1 0 0 0 1 0 0 1 0 1 0 0 1 0 0 0 0 1 0 0 1];

odfC = transformODF(odf,p2c,'variantSelection',vSel)
%odfC = transformODF(odf,p2c)

%%

plotPDF(odfC,hC,'antipodal')

%%

plot(odfC,'sigma')


%%

%%



vSel = unimodalODF(csP.rot(2),'halfwidth',20*degree)
vSelSym = FourierODF(vSel);
vSelSym = vSelSym.symmetrise('CS',csP);
vSel = vSel./vSelSym

plot(vSel,'sigma')

%%

plotIPDF(vSel,xvector)



%%
oR = fundamentalRegion(p2c.CS)

%odfP = unimodalODF(oR.V(1),'halfwidth',5*degree)
odfP = unimodalODF(orientation.id(p2c.CS),'halfwidth',5*degree)

plot(odfP,'sigma')
%%

odfC = transformODF(FourierODF(odfP),p2c,vSel)

%%

plotPDF(odfC,hC,'antipodal')

%%

plot(odfC,'sigma')

%%

for k = 1:24

  vSel = unimodalODF(csP.rot(k),'halfwidth',20*degree);
  vSelSym = FourierODF(vSel);
  vSelSym = vSelSym.symmetrise('CS',csP);
  vSel = vSel./vSelSym;

  odfP = unimodalODF(orientation.id(p2c.CS),'halfwidth',10*degree);

  odfC(k) = transformODF(FourierODF(odfP),p2c,vSel)

end

%%

plotPDF(odfC(7),hC,'antipodal')

%%

cor(odfC,odfC)





