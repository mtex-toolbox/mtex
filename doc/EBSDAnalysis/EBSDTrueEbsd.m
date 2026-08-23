%% TrueEBSD Distortion Correction
%
%%
% An EBSD map and an SEM image of the same area never quite line up: the beam
% drifts during the scan, the camera moves between acquisitions, the specimen
% is tilted. TrueEBSD corrects that, so every pixel of the map and every pixel
% of the images refer to the same point on the sample. What comes out is an
% ordinary EBSD map that carries the images as per-pixel properties.
%
% The method is due to Tong et al.,
% <https://arxiv.org/abs/2605.00703 arXiv 2605.00703>, and was first
% published as the separate TrueEBSD toolbox. Original authors: Vivian Tong;
% Stefan Olovsjö, Seco Tools AB, R&D Materials and Technology, 737 82
% Fagersta, Sweden.
%
% This page runs the whole workflow on a cut-down WC-Co dataset in well under
% a minute. See <trueEbsd2.trueEbsd2.html |trueEbsd2|> for the class,
% <mapImage.mapImage.html |mapImage|> for the container and
% <EBSDSpatialTransform.html Spatial Transforms> for the distortion models.
%
% The convention set here only decides which way up the figures come out. It
% has no effect on the correction: a map entry's array order is read off its
% own |d1| and |d2|, and no plotting convention is consulted anywhere in the
% workflow.

plottingConvention.default('y↓→x')

mtexdata trueEbsdWCCoSmall

display(ebsd.opt.trueEbsdImgs)

%% Build the Sequence
%
% TrueEBSD does not jump straight from the EBSD map to the reference image.
% It steps through the images one pair at a time, correcting one kind of
% distortion at each step - which is why there are four images rather than
% one. Each pair differs by something simple enough to model, where the map
% and the final image differ by everything at once.
%
% So the order matters. It runs from the *most* distorted to the ground
% truth. The images go in one list and the distortions in another, one per
% step. The reference is last.
%
% |'name'| is what each image is called once it is attached to the map at the
% end, so the result reads as |ebsd.fsdT1|.

img = ebsd.opt.trueEbsdImgs;

imgList = [mapImage(ebsd.bc, ebsd,                  'name','bcImg'), ...
  mapImage(img.fsdB3,  'dxy',img.pixSzImg, 'name','fsdB3'), ...
  mapImage(img.fsdT3,  'dxy',img.pixSzImg, 'name','fsdT3'), ...
  mapImage(img.fsdT1,  'dxy',img.pixSzImg, 'name','fsdT1'), ...
  mapImage(img.fsdT10, 'dxy',img.pixSzImg, 'name','fsdT10')];

%%
% A light box filter first - cross-correlation dislikes noise - and one
% common range, since the levels off different detectors mean nothing to each
% other. Both are methods of |mapImage| and both take the whole list at once.

imgList(2:end) = rescale(imboxfilt(imgList(2:end),3));

%%
% The distortions are objects, one per *hop*, not names on the images: beam
% drift plus a rigid offset, then nothing, then the camera moving, then the
% specimen tilt seen at a different kV. There are five maps and so four hops,
% and the reference has no entry of its own - where nothing separates a pair
% that is |spatialTransformId|.
%
% A multi-stage model is built with |+| and not |*|. |+| reads left to right
% in the order the stages are applied and keeps both of them, where an
% unfitted prototype has zero coefficients, so it reports itself as the
% identity and |*| would absorb it away.

T = [spatialTransformShift + spatialTransformDrift, ...
  spatialTransformId, ...
  spatialTransformShift, ...
  spatialTransformTilt];

%%
% The job holds the whole workflow, and each step below adds to it. Building
% it also checks that the sequence really is stored one consistent way round,
% and that every entry measures the sample in the same unit.

job = trueEbsd2(imgList,T)

%%
% Plot the sequence to check the images really do cover the same area. Note
% how different the contrasts look - that is why matching is done on edges
% rather than on the original values.

plot(imgList)

%% Put Everything on One Pixel Grid
%
% The map is on a 0.159 µm grid and the images on 0.0795 µm.
% |pixelSizeMatch| resamples them all onto the finest one, so pixel (i,j)
% means roughly the same place in each. Give it a pixel size to ask for a
% particular grid; with no argument it takes the smallest present.
%
% Images are interpolated linearly. EBSD data is not: orientations and phase
% labels have no meaningful average, so the nearest measured point is used.
%
% Nothing has been corrected yet - this is only bookkeeping.

job.pixelSizeMatch

%%
% The resampled sequence is in |job.resizedList|.

job.resizedList

%% Adjust the Matching Windows
%
% Distortions are measured by cutting both images of a pair into small boxes
% and cross-correlating each box with its partner - see
% <xcfShift.html |xcfShift|>. That gives a local shift at each box, and those
% shifts are fitted to the distortion model.
%
% Almost none of it has to be specified. The box width |roiSize| and the
% |edgeWidth| below are measured from the images themselves the first time
% |calcDistortion| needs them, and what was chosen is printed so it can be
% overridden. Both are *lengths*, in the map's own |scanUnit|, so they mean
% the same thing before and after |pixelSizeMatch| and may be set at any point.
%
% What is worth setting here is how many boxes to use. The default of 24
% across suits a full-size map; this grid is small, and the matching is the
% entire runtime, so fewer is quicker.

job.setOptions('numROI',16)

%% Measure the Distortion
%
% These are the pictures that will actually be matched. A band contrast map
% and a backscatter image have nothing in common as grey values, but their
% grain boundaries fall in the same places - which is why the edge transform
% is what gets correlated, and why |registerOn| defaults to |'edge'|. Set it
% to |'raw'| for a pair that already shares contrast.

plot(job.resizedList,'edge')

%%
% |'fitErr'| re-measures the shifts *after* each correction and reports what
% is left over. That residual is how you tell whether it worked: around a
% pixel or less is good.
%
% If a residual comes out above two pixels, TrueEBSD doubles the box size and
% tries again, repeating until it comes down or the box outgrows the image.
% The boxes set above are large enough that this does not happen here.
%
% Steps whose transform is |spatialTransformId| are skipped: nothing
% separates that pair, so their shift is taken as zero whatever the residual
% says.

job.calcDistortion('fitErr')

%%
% Afterwards |job.T| holds the *fitted* transforms rather than the prototypes
% it started from.

job.T

%% Correct It
%
% Each map is now moved by the shifts of every step between it and the
% reference. The reference itself does not move.
%
% Resampling is nearest-neighbour throughout, so no orientation and no phase
% label is ever invented by averaging two real measurements.

job.undistort

plot(job.undistortedList)

%% Use the Result
%
% Every image is now attached to the EBSD map as a per-pixel property, under
% the |'name'| given earlier. So |ebsd.fsdT1| is just another map property,
% and |plot(ebsd,ebsd.fsdT1)| works like any other plot - no conversion, and
% it stays with the map through cropping, gridding and indexing.
%
% Plotting them back onto the map is also the quickest check that nothing
% came out the wrong way round.
%
% |fsdB3| is a colour image and keeps all three channels. Plotting onto a map
% needs one value per pixel, so it is averaged to grey here.

ebsdOut = job.undistortedList(1).ebsd;

figure
nextAxis
plot(ebsdOut('W C'), ebsdOut('W C').orientations, 'coordinates','on')
title('Undistorted EBSD map (WC IPF out of screen)','Color','k')

for n = 1:numel(job.undistortedList)

  im = ebsdOut.(job.undistortedList(n).name);
  if size(im,3) > 1, im = mean(im,3); end

  nextAxis
  plot(ebsdOut, im, 'coordinates','on')
  mtexColorMap gray
  title(['Undistorted ' job.undistortedList(n).name],'Color','k')
end

%% Finish
%
% The map and the images now overlay pixel for pixel, and |ebsdOut| is an
% ordinary EBSD map that happens to carry four SEM images as properties.
% Anything you would normally do with a map works from here - including
% turning a thresholded image into a phase.
%
% |trueEbsdWCCoSmall| is the centre half of the full WC-Co field of view
% coarsened by four: a 20.4 x 15.3 µm area with WC grains about 12 px across,
% small enough to be quick and still large enough for every distortion to be
% measurable. The full dataset is |trueEbsdWCCo|, and the same script runs on
% it unchanged - it simply takes minutes rather than seconds.
