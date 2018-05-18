%% Birefrigence
%
% Birefringence is the optical property of a material having a refractive
% index that depends on the polarization and propagation direction of
% light. It is one of the oldest methods to determine orientations of
% crystals in thin sections of rocks.


%% Import Olivine Data
% In order to illustarte the effect of birefringence lets consider a
% olivine data set.

% The imported EBSD map contains mainly Olivine data
ebsd = loadEBSD('olivineopticalmap.ang')
cs = ebsd('olivine').CS;

% correct data to fit the reference frame
rot = rotation('Euler',90*degree,180*degree,180*degree);
ebsd = rotate(ebsd,rot,'keepEuler');
rot = rotation('Euler',0*degree,0*degree,90*degree);
ebsd = rotate(ebsd,rot);

% plotting conventions
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

% plot the olivine phase
plot(ebsd('olivine'),ebsd('olivine').orientations);


%% The refractive index tensor
%
% The refractive index of a material is described by a rank 2 tensor. 
% TODO: write some more words ;)


%%
% In the case of Olivine the refractive index tensor can be computed as
% follows.
% TODO ... some more words

% alpha : b-axis
% beta  : c-axis
% gamma : a-axis
% olivine smallest refractive index (alpha = X = Np : b-axis)
%     intermediate refractive index (beta  = Y = Nm : c-axis)
%          largest refractive index (gamma = Z = Ng : a-axis)
% form matrix in tensor format
% (1,1) = a-axis (2,2) = b-axis (3,3) = c-axis values of tensor
%  n a-axis     0            0
%  0            n b-axis     0
%  0            0            n c-axis

XFo = 0.86; % what is this?
n_alpha = 1.635*XFo + 1.82  * (1-XFo); % explain these formulae
n_beta  = 1.651*XFo + 1.869 * (1-XFo);
n_gamma = 1.670*XFo + 1.879 * (1-XFo);
rI = refractiveIndexTensor(diag([ n_gamma  n_alpha  n_beta]),cs)

%% Birefringence
% The birefringence describes the difference |dn| in wavespeed between the fastest
% polarization direction |nMax| and the slowest polarization direction
% |nMin| for a given propagation direction |vprop|.

% lets define a propagation direction
vprop = Miller(1,1,1,cs);

% and compute the birefringence
[dn,nMin,nMax] = rI.birefringence(vprop)

%%
% If the polarization direction is ommited the results are spherical
% functions which can be easily visualized.

% compute the birefringence as a spherical function
[dn,nMin,nMax] = rI.birefringence

% plot it
plot3d(dn,'complete')
mtexColorbar

% and on top of it the polarization directions
hold on
quiver3(nMin,'color','white')
quiver3(nMax)
hold off

%% The Optical Axis
% The optial axes are all directions where the birefringence is zero

% compute the optical axes
vOptical = rI.opticalAxis

% and check the birefringence is zero
rI.birefringence(rI.opticalAxis)

% annotate them to the birefringence plot
hold on
arrow3d(vOptical,'antipodal','facecolor','red')
hold off

%% Spectral Transmission
% If white with a certain polarization is transmited though a crystal with
% isotropic refrative index the light changes wavelength and hence appears
% collored. The resulting color depending on the propagation direction, the
% polarization direction and the thickness can be computed by

vprop = Miller(1,1,1,cs);
thickness = 30000;
p =  Miller(-1,1,0,cs);
rgb = rI.spectralTransmission(vprop,thickness,'polarizationDirection',p) 

%%
% Effectively, the rgb value depend only on the angle tau between the
% polariztzion direction and the slowest polarization direction |nMin|.
% Instead of the polarization direction this angle may be specified
% directly

rgb = rI.spectralTransmission(vprop,thickness,'tau',30*degree)

%%
% If the angle tau is fixed and the propagation direction is ommited as
% input MTEX returns the rgb values as a spherical function. Lets plot
% these functions for different values of tau.

newMtexFigure('layout',[1,3]);

mtexTitle('$\tau = 15^{\circ}$')
plot(rI.spectralTransmission(thickness,'tau',15*degree),'rgb')

nextAxis
mtexTitle('$\tau = 30^{\circ}$')
plot(rI.spectralTransmission(thickness,'tau',30*degree),'rgb')


nextAxis
mtexTitle('$\tau = 45^{\circ}$')
plot(rI.spectralTransmission(thickness,'tau',45*degree),'rgb')

drawNow(gcm)

%%
% Usually, the polarization direction is chosen at angle phi = 90 degree of
% the analyzer. The following plots demonstrate how to change this angle

newMtexFigure('layout',[1,3]);

mtexTitle('$\tau = 15^{\circ}$')
plot(rI.spectralTransmission(thickness,'tau',45*degree,'phi',30*degree),'rgb')

nextAxis
mtexTitle('$\tau = 30^{\circ}$')
plot(rI.spectralTransmission(thickness,'tau',45*degree,'phi',60*degree),'rgb')

nextAxis
mtexTitle('$\tau = 45^{\circ}$')
plot(rI.spectralTransmission(thickness,'tau',45*degree,'phi',90*degree),'rgb')

drawNow(gcm)

%% Spectral Transmission at Thin Sections
% All the above computations have been performed in crystal coordinates.
% However, in practical applications the direction of the polarizer as well
% as the propagation direction are given in terms of specimen coordinates.

% the propagation direction
vprop = vector3d.Z;

% the direction of the polarizer
polarizer = vector3d.X;

% the thickness of the thin section
thickness = 22800;

%%
% As usal we have two options: Either we transform the refractive index
% tensor into specimen coordinates or we transform the polarization
% direction and the propagation directions into crystal coordinates.
% Lets start with the first option:

% extract the olivine orientations
ori = ebsd('olivine').orientations;

% transform the tensor into a list of tensors with respect to specimen
% coordinates
rISpecimen = ori * rI;

% compute RGB values
rgb = rISpecimen.spectralTransmission(vprop,thickness,'polarizationDirection',polarizer);

% colorize the EBSD maps according to spectral transmission
plot(ebsd('olivine'),rgb)


%%
% and compare it with option two:

% transfom the propation direction and the polarizer direction into a list
% of directions with respect to crystal coordinates
vprop_crystal = ori \ vprop;
polarizer_crystal = ori \ polarizer;

% compute RGB values
rgb = rI.spectralTransmission(vprop_crystal,thickness,'polarizationDirection',polarizer_crystal);

% colorize the EBSD maps according to spectral transmission
plot(ebsd('olivine'),rgb)


%% Spectral Transmission as a color key
% The above computations can be automized by defining a spectral
% transmission color key.

% define the colorKey
colorKey  = spectralTransmissionOrientationMapping(rI,thickness);

% the following are the defaults and can be ommited
colorKey.propagationDirection = vector3d.Z; 
colorKey.polarizer = vector3d.X; 
colorKey.key = 90 * degree;

% compute the spectral transmission color of the olivine orientations
rgb = colorKey.orientation2color(ori);


% TODO: this command requires the image procession toolbox
%       can't this be implemented directly?
%rgb = imadjust(rgb,[],[],.5);

plot(ebsd('olivine'), rgb)


%%
% As usual we me visualize the color key as a colorization of the
% orientation space, e.g., by plotting it in sigma sections:

plot(oMc,'sigma')

%% Circular Polarizer
% In order to simulate we a circular polarizer we simply set the polarizer
% direction to empty, i.e.

colorKey.polarizer = []; 

% compute the spectral transmission color of the olivine orientations
rgb = colorKey.orientation2color(ori);

plot(ebsd('olivine'), rgb)



%% Illustrating the effect of rotating polarizer and analyser simultanously

% commment this out to save the result as a animated gif
% filename = 'testanimated2.gif';

figure
plotHandle = plot(ebsd('olivine'),oMc.orientation2color(ori));
textHandle = text(750,50,[num2str(omega,'%10.1f') '\circ'],'fontSize',15,...
  'color','w','backGroundColor','k');

% define the step size in degree
stepSize = 15;

for omega = 0:stepSize:360-stepSize
    
  % update polarsation direction
  oMc.polarizer = rotate(vector3d.X, omega * degree);
    
  % update rgb values
  plotHandle.FaceVertexCData = oMc.orientation2color(ori);
  
  % update text
  textHandle.String = [num2str(omega,'%10.1f') '\circ'];
  
  drawnow
  
  % Capture the plot as an image
  if exist('filename','var')
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if omega == 0
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.01);
    else
      imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
  end
end


%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% I went up to this point 
% maybe you can explain and document a bit better what you wanted to do
% below

%%  plot sphere of interference colour with the extinction part
% somehow it is not posible to do this with the pCS

vprop = plotS2Grid;
p = xvector;
% plot xvector along great circles
rotaxis = xvector;
greatcirclerotation1 = rotation('axis',rotaxis,'angle',vprop.rho);
p = rotate(p,greatcirclerotation1);
rotaxis =yvector;%cross(yvector,vprop);
greatcirclerotation2 = rotation('axis',rotaxis,'angle',vprop.theta);
p =rotate(p,greatcirclerotation2);
filename = 'testanimated4.gif';
h =figure;
axis tight manual
stepSize = 15;
for omega = 0:stepSize:360
  rot = rotation('axis',zvector,'angle',omega*degree);
  polarisationdirection = rot.*p;
  pCS=polarisationdirection;
  rgb2 = spectralTransmission(rI,vprop,thickness,'polarizationDirection',pCS);
  %rgb2 = spectralTransmission(rI,vprop,thickness,'polarizationDirection',polarisationdirection);
  %rgb2=imadjust(rgb2,[],[],0.5)*1.0;
  plot3d(vprop,rgb2)
  az = 55;
  el = 60;
  view(az, el);
  text(0,1.8,3.2,[num2str(omega,'%10.1f') '\circ'],'fontSize',15,'color','w','backGroundColor','k');
  drawnow
  % Capture the plot as an image
  frame = getframe(h);
  im = frame2im(frame);
  [imind,cm] = rgb2ind(im,256);
  % Write to the GIF File
  if omega == 0
    imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.05);
  else
    imwrite(imind,cm,filename,'gif','WriteMode','append');
  end
end


%%
opticaxisol = opticalAxis(rI);
bxa=mean(opticaxisol);
OA_rotation =  rotation('map',zvector,opticaxisol);
bxa_rotation = rotation('map',zvector,bxa);
rI_OA = rotate(rI,OA_rotation(1));
%rI_OA = rotate(rI,bxa_rotation);%actually BXA
vprop = plotS2Grid('maxTheta',pi()/2);%5,'minRho',0,'maxRho',365*degree);
p = xvector;
%plot xvector along great circles
rotateZ2vprop=rotation('map',vprop,zvector);
%p=rotate(p,rotateZ2vprop);
p = inv(rotateZ2vprop).*p;
figure
%scatter(vprop(1:5:end))
quiver3(vprop(1:15:end),p(1:15:end));
alpha = angle(p,vprop)/degree;
figure;plot(vprop,alpha)
% hold on
% quiver3(vprop(1:15:end),vprop(1:15:end));
% hold off
% figure
% plot(vprop(1:15:end));

%%

filename = 'testanimated8.gif';
thickness = 30000;
h =figure;
axis tight manual
for omega = 0:5:360
rot = rotation('axis',zvector,'angle',omega*degree);
%polarisationdirection =rot.*p;
rI_OA_rot =rotate(rI_OA,rot);

pCS=p;
rgb2 = spectralTransmission(rI_OA_rot,vprop,thickness,'polarizationDirection',pCS);
   %rgb2 = spectralTransmission(rI,vprop,thickness,'polarizationDirection',polarisationdirection);
   rgb2=imadjust(rgb2,[],[],0.5)*1.0;
   plot3d(vprop,rgb2)
   az = 88;
   el = 55;
    view(az, el);
   text(0,1.5,1.5,[num2str(omega,'%10.1f') '\circ'],'fontSize',15,'color','w','backGroundColor','k');
   hold on
   arrow3d(zvector*1.2)
   hold off
   drawnow 
      % Capture the plot as an image 
      frame = getframe(h); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if omega == 0 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.05); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
end     

   
   %%
   figure()
   plot(vprop,rgb2) 
   %%
   [nxx,nMinxx,nMaxxx] = birefringence(rI,vprop);
     
   figure;quiver3(vprop(1:15:end),nMinxx(1:15:end))
%%
vprop = equispacedS2Grid('maxTheta',pi()/2);%5,'minRho',0,'maxRho',365*degree);
p = xvector;
%plot xvector along great circles
rotateZ2vprop=rotation('map',vprop,zvector);
%p=rotate(p,rotateZ2vprop);
p = inv(rotateZ2vprop).*p;
pCS =p;
x =vprop.x;
y =vprop.y;
u =pCS.x;
v =pCS.y;
figure
omega = 3;
quiver(x(1:omega:end),y(1:omega:end),u(1:omega:end),v(1:omega:end));
figure
plot(vprop,abs(pCS.x));mtexColorbar;mtexTitle 'pCS.x'
nextAxis
plot(vprop,abs(pCS.y));mtexColorbar;mtexTitle 'pCS.y'
nextAxis
plot(vprop,pCS.z);mtexColorbar;mtexTitle 'pCS.z'
figure
plot(vprop,(pCS.rho));mtexColorbar;mtexTitle 'pCS.rho'
nextAxis
plot(vprop,(pCS.theta));mtexColorbar;mtexTitle 'pCS.theta'

%% failed attempt to make streamlines on the sphere
number_of_lines = 20;
[startx, starty]= meshgrid(linspace(min(min(x)),max(max(x)),number_of_lines),linspace(min(min(y)),max(max(y)),number_of_lines));
% starty = linspace(min(min(y)),max(max(y)),number_of_lines);
% startx = zeros(size(starty));%starty=starty*pi()/2.1
h =streamline(x,y,u,v,startx,starty);

%vlines = vector3d(number_of_lines,size(startx))
 %5for i =1:number_of_lines
vlines = vector3d('polar',h(30).YData,h(30).XData)
 %end
figure
plot(vlines)
