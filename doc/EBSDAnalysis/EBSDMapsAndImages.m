%% EBSD Maps and SEM Images
%
%%
% An EBSD map and a forescatter or BSE image of the same area are two
% rasters of the same piece of specimen. Putting them together needs two
% questions answered, and they are independent of each other:
%
% * where on the specimen does each picture sit - its
% <referenceFrame.referenceFrame.html reference frame>
% * which way round is each array stored - its
% <gridLayout.gridLayout.html layout>
%
% The first decides what is drawn where. The second decides what |img(i,j)|
% means. This page walks through both on one WC-Co dataset, an EBSD map and
% four forescatter images of the same 20 × 15 micron area.

plottingConvention.default('y↓→x');

mtexdata trueEbsdWCCoSmall

img = ebsd.opt.trueEbsdImgs;

%%
% <mapImage.mapImage.html |mapImage|> is a picture together with the geometry
% that says where it sits: an origin, a pixel size and the frame those refer
% to. A channel of an EBSD map joins such a sequence as one entry of it, so a
% map and its images are one array rather than two different kinds of thing.

imgList = [mapImage(ebsd.bc,ebsd,         'name','bcImg'), ...
  mapImage(img.fsdT1, 'dxy',img.pixSzImg, 'name','fsdT1'), ...
  mapImage(img.fsdT10,'dxy',img.pixSzImg, 'name','fsdT10')]

%%
% Plotting the sequence draws each entry where it sits, one axis per picture

plot(imgList,'layout',[1,3],'refFrame','on')

%% What an Image Does Not Know
%
% The map entry brings the map's frame along, so it knows the specimen

imgList(1).frame

%%
% An image does not. Which specimen direction its x runs along is not in the
% array and cannot be computed from it - somebody has to say. Until they do,
% MTEX gives the image a frame of its own rather than assuming the map's, and
% names its axes |iX|, |iY|, |iZ| so that every plot and every display shows
% they are the image's own

imgList(2).frame

%% Two Pictures That Disagree
%
% Here everything was collected in one session, which is why the plots above
% agree. To get the other case, turn the map through 90 degree - what a stage
% rotation between the two acquisitions would leave you with.

ebsd = rotate(ebsd,90*degree);

imgList = [mapImage(ebsd.bc, ebsd,         'name', 'bcImg'), ...
  mapImage(img.fsdT1, 'dxy', img.pixSzImg, 'name', 'fsdT1'), ...
  mapImage(img.fsdT10,'dxy', img.pixSzImg, 'name', 'fsdT10')]

%%
% The map's array is 128 × 96 now where the pictures are 192 × 256 - the two
% are transposed to each other. Plotting shows it at once: the map is on its
% side relative to the images, and somewhere else on the specimen

plot(imgList,'layout',[1,3],'refFrame','on')

%% Saying Which Way Round the Map Is
%
% Each entry is drawn the way its own frame says it should be, so changing
% the map's frame changes what you see. Turn it until the plots agree with
% each other; here the map needs |'x↑→y'| and the images keep the default.
%
% This is the part only you can supply. It is a fact about how the data was
% collected, and no amount of looking at the numbers will recover it.

ebsdFrame = imgList(1).frame;
ebsdFrame.how2plot = 'x↑→y';

plot(imgList,'layout',[1,3])

%%
% All three now agree on screen, and that is a statement about the specimen:
% <orientation.byScreenAlignment.html |byScreenAlignment|> means exactly *I
% have plotted these and they are the same way up*.
% <mapImage.transformReferenceFrame.html |transformReferenceFrame|> takes
% that statement and restates every entry in one frame

imgList = transformReferenceFrame(imgList,ebsdFrame,'byScreenAlignment')

%%

plot(imgList,'layout',[1,3])

%% How the Array Is Stored
%
% Look at the |layout| column above. It changed too, and so did the shape of
% the map - a 128 × 96 array came back 96 × 128. That is the second question,
% and it has nothing to do with the specimen: it is the order the numbers sit
% in memory.
%
% The layout is a <gridLayout.gridLayout.html |gridLayout|>, and there is
% nothing more to it than two directions - the one the row index advances
% along, and the one the column index advances along, in that order

imgList(1).layout

%%
% Every |mapImage| states its own, and so does a gridded map

ebsd.layout

%% Putting a Map in an Image's Layout
%
% |gridify| takes such a layout, which is how a map is put in the same order
% as a picture it is to be compared with. |'columnMajor'| and |'rowMajor'|
% are the two it knows by name - see <EBSDGrid.html Square and Hex Grids> -
% and any other is stated as a |gridLayout|. Start again from the map as it
% was imported, and say the detector had been mounted a quarter turn from
% the scan, so its rows run against x and its columns along y

mtexdata trueEbsdWCCoSmall silent

gL = gridLayout(-xvector,yvector)

%%
% Then the map goes into that layout and its shape follows

ebsdI = gridify(ebsd,gL)

%%
% Nothing was resampled and no value invented - a transpose and two flips are
% all that is ever applied, which is why this is safe to do to orientation
% data. For this particular pair of layouts it is a quarter turn, and it
% really is only that

isequal(ebsdI.bc, rot90(ebsd.bc))

%%
% so putting it back is exact

isequal(gridify(ebsdI,ebsd.layout).bc, ebsd.bc)

%%
% Note what has *not* changed. The layout is how the measurements are stored,
% not where the specimen is, so the map still plots the same way up - MTEX
% moves the camera for the screen, never the data

plot(ebsd,ebsd.bc,'micronbar','off','layout',[1,2]), mtexColorMap gray
title('as imported')
nextAxis
plot(ebsdI,ebsdI.bc,'micronbar','off'), mtexColorMap gray
title('row ||-x, col ||y')

%% Comparing Them Pixel by Pixel
%
% Once the frames agree and the layouts agree, the two rasters are ordinary
% matrices of the same thing and may be handed to any image processing tool
% side by side. What is still missing is a common pixel grid: the map here is
% on 0.159 micron and the images on 0.0795.
%
% <mapImage.interp.html |interp|> resamples an image at any positions, so the
% map's own are all it takes. The image has no origin of its own - that was
% the first question again - so state where its first pixel sits.

mgI = mapImage(img.fsdT1,'dxy',img.pixSzImg,'origin',ebsd.pos(1,1));

ebsd.prop.fsdT1 = interp(mgI,ebsd.pos);

%%
% From here the image is just another property of the map, and travels with
% it through cropping, gridding and indexing

plot(ebsd,ebsd.fsdT1)
mtexColorMap gray

%%
% The two still do not overlay perfectly: the beam drifts during a scan, the
% camera moves between acquisitions, the specimen is tilted. Each of those is
% a <EBSDSpatialTransform.html spatial transform> that can be fitted from the
% two pictures and taken back out, which is
% <EBSDTrueEbsd.html what TrueEBSD does> - and it starts exactly here,
% with a sequence whose entries agree about the specimen and about the order
% they are stored in.
%
% See also <EBSDGrid.html Square and Hex Grids> for what a layout is good
% for, and <EBSDReferenceFrame.html Reference Frame Alignment> for the other
% frame question a map raises - whether its Euler angles and its coordinates
% refer to the same axes.
