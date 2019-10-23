%% Quasi symmetry
%

% Aufstellung 1
% mit fünfzähliger Achse parallel zu z
%rot5 = rotation.byAxisAngle(zvector,(0:4)*72*degree)
%rot3 = rotation.byAxisAngle(vector3d('polar',37.377*degree,0) ,(0:2)*120*degree)

% Aufstellung 2
% mit zweizähliger Achse parallel zu z
rot5 = rotation.byAxisAngle(vector3d('polar',31.7171*degree,0),(0:4)*72*degree)
rot3 = rotation.byAxisAngle(vector3d('polar',20.9054*degree,90*degree),(0:2)*120*degree)

% generiere Gruppe indem wir die Operationen ein paar mal hintereinander
% ausführen und alles doppelte wegschmeissen :)
rot = unique(rot3 * rot5 * rot3 * rot5 * rot3 * rot5)

% definiere das als crystal symmetry -> enantiomorphe gruppe
cs = crystalSymmetry(rot)

% nehme inversion dazu
%cs = crystalSymmetry([1 -1]*rot)

plot(cs,'symbolSize',0.4,'projection','eangle','grid','on')

hold on
plot(cs.fundamentalSector,'color','red')
hold off


%%

oR = cs.fundamentalRegion
plot(oR)

%%


ipfKey = ipfHSVKey(cs);

plot(ipfKey,'complete','upper','projection','eangle','resolution',0.5*degree)

%saveFigure('ipfKey3.png')
