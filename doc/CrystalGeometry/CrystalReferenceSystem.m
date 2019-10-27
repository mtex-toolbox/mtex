%% The Crystal Reference System
%
%%
% Commonly the crystal coordinate system is defined by the crystallographic
% axes a, b, c. The length [a,b,c] and the angles [alpha,beta,gamma]
% between theses axes needs to be specified when defining a variable of
% type <crystalSymmetry.crystalSymmetry.html crystalSymmetry>.
%

cs = crystalSymmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree])

%% Need of a Euclidean reference system
%
% However, there are may crystal properties, like orientation or tensorial
% properties, that are most commonly described with respect to an Euclidean
% reference system as oposed to the crystallographic axes a, b, c. Most
% importantly, Euler angles as a decription of an orientations is described
% as subsequent rotations about the z, x and z axis. Hence, we need to
% inscribe an Eucledian reference system x, y, z into crystallogaphic
% reference system a, b, c.
% 
%% Cubic, tetragona and orthorhombic symmetries
%
% In orthorhombic, tetragonal and cubic crystal symmetry the crystal
% reference system a, b, c is itsself an Euclidean one and, hence, setting
% x parallel to a, y parallel to b and z parallel to c is a canonical
% choice. 
%
% As for such symmetries this is also the default in MTEX there is no need
% to specify the alignment seperately.
%
%% Trigonal and hexagonal materials
%
% For trigonal and hexagonal materials the z axis is commonly aligned with
% the c axis. As for the x and y axes they are either aligned with the a or
% b axes. 
% 
% The following command alignes the x axes to the a axes and the z axes to
% the c axes. 

cs_x2a = crystalSymmetry('321',[1.7,1.7,1.4],'X||a','Z||c');

% visualize the resuls
plot(cs_x2a)
annotate(cs_x2a.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')
annotate(cs_x2a.bAxis,'MarkerFaceColor','r','label','b','backgroundColor','w')
annotate(-vector3d.Y,'MarkerFaceColor','green','label','-y','backgroundColor','w')
annotate(-vector3d.X,'MarkerFaceColor','green','label','-x','backgroundColor','w')
%%
% In contrast the following command alignes the y axes to the a axes and
% the z axes to the c axes.

cs_y2a = crystalSymmetry('321',[1.7,1.7,1.4],'y||a','Z||c');
plot(cs_y2a)
annotate(cs_y2a.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')
annotate(cs_y2a.bAxis,'MarkerFaceColor','r','label','b','backgroundColor','w')
annotate(-vector3d.Y,'MarkerFaceColor','green','label','-y','backgroundColor','w')
annotate(-vector3d.X,'MarkerFaceColor','green','label','-x','backgroundColor','w')

%%
% The only difference between the above two plots is the position of the x
% and y axes. The reason is that visualizations relative to the crystal
% reference system, e.g., inverse pole figures, are in MTEX aligned on the
% screen according to the b-axis. 
%
% This on secreen alignment can be easily modified by

% change on screen alignment
plota2east

% redo last plot
plot(cs_y2a)
annotate(cs_y2a.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')
annotate(cs_y2a.bAxis,'MarkerFaceColor','r','label','b','backgroundColor','w')
annotate(-vector3d.Y,'MarkerFaceColor','green','label','-y','backgroundColor','w')
annotate(-vector3d.X,'MarkerFaceColor','green','label','-x','backgroundColor','w')

% set old default back
plotb2east

%%
% It should be stressed that the alignment between the Eucledean crystal
% axes x, y, z and the crystallographic axes a, b and c is crucial for many
% computations. The difference between both setups becomes more vsible if
% we plot crystal shapes in the x, y, z coordinate system

cS_x2a = crystalShape.quartz(cs_x2a)

close all
figure(1)
plot(cS_x2a)
hold on
arrow3d(0.5*[xvector,yvector,zvector],'labeled')
hold off

%%

cS_y2a = crystalShape.quartz(cs_y2a)

figure(2)
plot(cS_y2a)
hold on
arrow3d(0.5*[xvector,yvector,zvector],'labeled')
hold off


%%
% Most important is the difference if Euler angles are used to describe
% orientation. Lets consider the following two orientations

ori_x2a = orientation.byEuler(0,0,0,cs_x2a)
ori_y2a = orientation.byEuler(0,0,0,cs_y2a)

%%
% and visualize them in a pole figure. 

newMtexFigure('innerPlotSpacing',20)
plotPDF(ori_x2a,Miller(1,0,0,cs_x2a),'MarkerSize',20)
annotate([xvector,yvector],'label',{'x','y'},'backgroundColor','w')
nextAxis
plotPDF(ori_y2a,Miller(1,0,0,cs_y2a),'MarkerSize',20)
annotate([xvector,yvector],'label',{'x','y'},'backgroundColor','w')
drawNow(gcm,'figSize','medium')

%%
% We observe that both pole figures are rotated with respect to each other
% by 30 degree. Indeed computing the misorientation angle between both
% orientations gives us

angle(ori_x2a, ori_y2a) ./ degree

%%
% In many cases MTEX automatically recognizes different setups and corrects
% for this. In order to manually transform orientations or tensors from one
% reference frame into another reference frame one might use the command
% <orientation.transformReferenceFrame.html transformReferenceFrame>. The
% following command transfroms the reference frame of orientation |ori_y2a|
% into the reference frame |cs_x2a|

ori_x2a.transformReferenceFrame(cs_y2a)


%% Triclinic and monoclinic symmetries
%
% In triclinic and monoclinic symmetries even more different setups are
% used. As two perpedicular crystal axes are required to align with x, y or
% z one ussually chooses one crystal axis from the direct coordinate
% system, i.e., a, b or c, and the second crystal axis from the reciprocal
% axes a*, b* or c*. Typical examples for such setups are

cs = crystalSymmetry('-1', [8.290 12.966 7.151], [91.18 116.31 90.14]*degree,...
  'x||a*','y||b', 'mineral','An0 Albite 2016')

%%
% or

cs = crystalSymmetry('-1', [8.290 12.966 7.151], [91.18 116.31 90.14]*degree,...
  'x||a','c||c*', 'mineral','An0 Albite 2016')

