cs = symmetry('6mm');
ss = symmetry('mmm');

q1 = axis2quat(xvector+zvector,40*degree);
q2 = axis2quat(vector3d(1,2,1),70*degree);
q3 = axis2quat(xvector-2*zvector,20*degree);

odf = 0.5*unimodalODF(q1,cs,ss) + ...
  0.5*fibreODF(Miller(1,1,0),vector3d(1,3,1),cs,ss)+...
  2*unimodalODF(q2,cs,ss) + ...
  0.5*unimodalODF(q3,cs,ss);

%%
plotPDF(odf,[Miller(1,0,0),Miller(1,1,1),Miller(0,0,1),Miller(1,1,0)],'contourf','antipodal')
mtexColorMap white2black

%%
plotIPDF(odf,[xvector,yvector,vector3d(1,1,1)],'complete')

%% 

annotate([q1,q2,q3,q])


%%

q = calcModes(odf)

%%
figure(2)
plotODF(odf,'complete')
mtexColorMap white2black

%%

plotODF(odf,'alpha','projection','plain','sections',5)

%%

annotate([q1,q2,q3,q],'MarkerSize',30,'MarkerFaceColor','none','MarkerEdgeColor','w')

%%

annotate(q)
