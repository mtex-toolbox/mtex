%%



cs = crystalSymmetry('m-3m')

plot(cs)

%plot(cs.fundamentalSector,'color',[0.8 0.8 0.8],'linewidth',1)

sR = cs.fundamentalSector(50*degree)

hold on
plot(sR,'color','red','linewidth',2)
hold off





%%

S2G = plotS2Grid(sR)

hold on
pcolor(S2G,cos(3*S2G.theta).^2+sin(10*S2G.rho).^2)
hold off

%% check disorientation

plotx2east

cs = crystalSymmetry('m-3m')


q = SO3Grid(5000,cs)

abcd = disorientation(squeeze(double(q)),Laue(cs));

q2 = quaternion(abcd(:,1),abcd(:,2),abcd(:,3),abcd(:,4))

figure(1)
plot(axis(q2))

ebsdColorbar(cs,'antipodal')

%%


%% EBSD region of interest
% First define a polygonal region by [x1 y1; x2 y2; x3 y3; x4 y4 etc]
region = [0 200; 0 275; 100 350; 380 350; 510 150; 500 60; 230 20; 0 200];
ind = inpolygon(ebsd,region); % select region of polygon
ebsd_plagioclase_crystal = ebsd(ind); % select EBSD data within region
plot(ebsd_plagioclase_crystal)
hold on
plot(region(:,1),region(:,2),'-r','linewidth',3)
hold off
%% plot EBSD Orientation map (region of interest)
figure('position',[0 0 plot_w plot_h])
plot(ebsd)
hold on
plot(region(:,1),region(:,2),'-r','linewidth',3)
hold off
savefigure('/MatLab_Programs/Francoise/02OF60/Zone1_EBSD_Orientation_Map_Selected.png')

%% EBSD region of interest
% Loop defining selected region as a polygon

mtexdata forsterite

plot(ebsd)


%%

disp('Define selected region of map using the curse and mouse')
disp('The last point does not need to exactly the first point')
disp('as the program ensures the polygon is closed')
disp('Left mouse button picks points')
disp('Right mouse button picks last point somewhere near the first point')
% Initialize the list of points (region) is empty.
region = [];
n = 0;
but = 1;
hold on
while but == 1
    [xi,yi,but] = ginput(1);
    
    plot(xi,yi,'s','MarkerFaceColor','k','MarkerEdgeColor','w','MarkerSize',10)
    n = n+1;
    region(n,:) = [xi,yi];
end

% ensure the polygon is always closed
region(n+1,:) = region(1,:);

% select region of polygon
ind = inpolygon(ebsd,region);
% select EBSD data within region 
ebsd_plagioclase_crystal = ebsd(ind);
plot(region(:,1),region(:,2),'-k','linewidth',2)

figure
plot(ebsd_plagioclase_crystal)


%% plot EBSD Orientation map (region of interest)
figure('position',[0 0 plot_w plot_h])
plot(ebsd)
hold on
plot(region(:,1),region(:,2),'-r','linewidth',3)
hold off
savefigure('/MatLab_Programs/Francoise/02OF60/Zone1_EBSD_Orientation_Map_Selected.png')



