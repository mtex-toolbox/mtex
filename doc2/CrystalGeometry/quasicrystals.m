%rot5 = rotation.byAxisAngle(zvector,(0:4)*72*degree)
%rot3 = rotation.byAxisAngle(vector3d('polar',37.377*degree,0) ,(0:2)*120*degree)

rot5 = rotation.byAxisAngle(vector3d('polar',31.7171*degree,0),(0:4)*72*degree)
rot3 = rotation.byAxisAngle(vector3d('polar',20.9054*degree,90*degree),(0:2)*120*degree)


rot = unique(rot3 * rot5 * rot3 * rot5 * rot3 * rot5)


cs = crystalSymmetry(rot)
%cs = crystalSymmetry([1 -1]*rot)

plot(cs,'symbolSize',0.4,'projection','eangle','grid','on')

hold on
plot(cs.fundamentalSector,'color','red')
hold off




%%

oR = cs.fundamentalRegion
plot(oR)

%%


ipfKey = ipfHSVKey(cs)

plot(ipfKey,'complete','upper','projection','eangle ')

%saveFigure('ipfKey3.png')

%%

