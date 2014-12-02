
%% visuallization in 3d

clf
% define some symmetry
cs = crystalSymmetry('-6m2','2||a')

% define the colorcoding
oM = ipdfHSVOrientationMapping(cs);

% rotate the colorball
% I managed to put always blue to the a-axis and red to the c-axis
% I you are unhappy with the result you can use a rotation
% to cirlce trough the colors, e.g. the next command would bring green to
% the c-axis
% oM.colorPostRotation = rotation('axis',zvector,'angle',120*degree);

% You can also interchange blue and gree while keeping red at the c-axis.
% This is done by mirroring the color sphere, i.e. by
% oM.colorPogetMinAxes(cs)stRotation = reflection(yvector);
% for 4mm
%oM.colorPostRotation = rotation('axis',zvector,'angle',0*degree)*rotation('axis',yvector,'angle',90*degree);

% plot the colorcoding
plot(oM,'3d')

% add some axes
hold on
gray = [0.4 0.4 0.4];
arrow3d(cs.axes(1),'facecolor',gray)
text3(cs.axes(1),'a_1','horizontalAlignment','right')

arrow3d(cs.axes(2),'facecolor',gray)
text3(cs.axes(2),'a_2','verticalAlignment','cap','horizontalAlignment','left')

arrow3d(cs.axes(3),'facecolor',gray)
text3(cs.axes(3),'c','verticalAlignment','bottom')
hold off

%savefigure('x.png')

%% visalization in 2d
% correct: -3, a||y, -6 a||x,

% blue to green color jump: -1, 2/m, -3
% green not at Miller(1,0,0): 121, 2/m11, m2m, 312, -6m2,

plotx2east

cs = crystalSymmetry('pointId',43,'a||x');

% define the colorcoding
oM = ipdfHSVOrientationMapping(cs);
%oM.colorPostRotation = reflection(zvector) * reflection(yvector);
%oM.colorPostRotation = rotation('axis',xvector,'angle',180*degree);
%oM.colorPostRotation = rotation('axis',zvector,'angle',0*degree)*rotation('axis',yvector,'angle',90*degree);

%oM.alpha = 0.3;
% plot the colorcoding
plot(oM,'complete','position',[100 100 800 400])
%plot(oM,'complete','projection','eangle')

% if you can not see anything you might want to try
% set(gcf,'renderer','zBuffer')
% or
% set(gcf,'renderer','openGL')
% maybe one of these two works

hold on

% add symmetry elements - comment out next line to see the result
plot(cs)

% plot fundamental sector - comment out next line to see the result
hold on
plot(cs.fundamentalSector,'color','r')

% add some axes
hold on
plot(cs.axes,'label',{'a_1','a_2','c'},'MarkerEdgeColor','white',...
    'backgroundcolor','none','Marker','s','MarkerFaceColor','black')

hold off

%% some script that runs through all point group an plot the visuallization to file

% impossible: 2, 10, 15, ,29

for i = 1:32
  
  close all
  cs = crystalSymmetry('pointId',i,'2||c');
  
  oM = ipdfHSVOrientationMapping(cs);

  % plot the colorcoding  
  plot(oM,'complete','position',[100 100 800 400
    ])
  
  hold on
  plot(cs)
  
  %hold on
  %plot(cs.axes,'label',{'a_1','a_2','c'},'MarkerEdgeColor','white',...
  %  'backgroundcolor','w','Marker','s','MarkerFaceColor','black')
  
  hold off
      
  % comment out next line to store to file
  %savefigure(['om/3d_' symmetry.pointGroups(i).Schoen '.png'])
  
  %
  pause
end

% to be checked: 3m (12)

%% improved rainbow colors
% this is some illustration how I have altered the color space
% first the normal rainbow distribution
% note the thin stripes for yellow, cyan and mangenta
% the second plot are the rescaled rainbow colors

close all
x = linspace(0,1);

rgb = hsv2rgb([x(:),ones(length(x),2)]);

rgb = reshape([rgb;rgb],100,2,3);

subplot(1,2,1)
surf(ones(100,2),[rgb]), shading flat
setCamera('default')

% next the rescalled rainbow colors. Put both plots side by sie

%figure(3)
z = linspace(0,1,1000);

% the scaling function
r = 0;f = 0.5 + exp(- 200.*(mod(z-r+0.5,1)-0.5).^2);
g = 0.33;f = f + exp(- 200.*(mod(z-g+0.5,1)-0.5).^2);
b = 0.66;f = f + exp(- 200.*(mod(z-b+0.5,1)-0.5).^2);
%f = f + exp(- 200.*(mod(z+0.5,1)-0.5).^2);

f = f./sum(f);
%plot(z,f)
f = cumsum(f);

x = linspace(0,1);
y = interp1(z,f,x);

rgb = hsv2rgb([y(:),ones(length(y),2)]);

rgb = reshape([rgb;rgb],100,2,3);

subplot(1,2,2)
surf(ones(100,2),rgb), shading flat
setCamera('default')
