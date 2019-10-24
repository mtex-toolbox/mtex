%% Transparencys
%
%%
cs = crystalSymmetry('m-3m')
odf = unimodalODF(orientation.id(cs))
ori = odf.discreteSample(500)

h = Miller({1,0,0},{1,1,0},{1,1,1},cs);
plotPDF(ori,h,'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.5,'MarkerSize',10,'all')
