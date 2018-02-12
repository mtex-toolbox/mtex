
% the crystal symmetry
cs = crystalSymmetry('222',[4.779 10.277 5.995])

% the three slip systems
sS1 = slipSystem(Miller(1,0,0,cs,'uvw'),Miller(0,1,0,cs,'hkl'))
sS2 = slipSystem(Miller(1,0,0,cs,'uvw'),Miller(0,0,1,cs,'hkl'))
sS3 = slipSystem(Miller(0,0,1,cs,'uvw'),Miller(0,1,0,cs,'hkl'))

% the macroscopic strain tensor
epsilon = 0.5*tensor([0.5 0 0; 0 0.5 0; 0 0 -1],'name','strain')

% now the components are entirely defined by slip system and strain tensor
odf1 = strainSBF(sS1,epsilon)
odf2 = strainSBF(sS2,epsilon)
odf3 = strainSBF(sS3,epsilon)

%% ODF sections

plot(odf3,'phi1','xAxisDirection','north','sections',1)

mtexColorbar


%% Pole Figure plots

h = Miller({1,0,0},{0,1,0},{0,0,1},cs);
figure(1)
plotPDF(odf1,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

figure(2)
plotPDF(odf2,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

figure(3)
plotPDF(odf3,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%%

figure(4)
plotPDF(odf1 + odf3,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%%

figure(2)
plotPDF(rotation('axis',xvector,'angle',30*degree) * odf1,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar


%%

figure(2)
plotPDF(odf2,h,'resolution',2*degree,'colorRange','equal')
mtexColorbar

%%

figure(1)
plotIPDF(odf1,xvector,'complete','resolution',2*degree)
annotate(h,'labeled')
figure(2)
plotIPDF(odf2,xvector,'complete','resolution',2*degree)
annotate(h,'labeled')
figure(3)
plotIPDF(odf3,xvector,'complete','resolution',2*degree)
annotate(h,'labeled')

%%

%oS = sigmaSections(cs)
oS = pfSections(cs,specimenSymmetry,'sections',12)
oS.referenceField = @(r) pfSections.polarField(r,vector3d.Z);

figure(1)
plotSection(odf1,oS)

%%

figure(2)
plotSection(odf1,oS)

%%

% you can take any combination of these components
odf = 0.2 * odf1 + 0.3*odf2 + 0.5*odf3;

% and plot the corresponding ODF
plotPDF(odf,Miller({1,0,0},cs))