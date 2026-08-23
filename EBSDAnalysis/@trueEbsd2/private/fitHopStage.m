function [ps,T] = fitHopStage(imRef,imTest,proto,xcf,dx,dy)
% measure one pair and fit one stage of its distortion
%
% Replaces fRunDIC. The correlation was already MTEX's xcfShift; this moves
% the fitting there too, so the Curve Fitting and Statistics calls go and the
% model is the transform class rather than a string naming a surface fit.
%
% Syntax
%
%   [ps,T] = fitHopStage(imRef,imTest,proto,xcf,dx,dy)
%
% Input
%  imRef, imTest - the two images, already on one grid
%  proto         - @spatialTransform, the unfitted prototype for this stage
%  xcf           - the tile settings for this stage: ROISize in pixels and
%                  NumROI across
%  dx, dy        - pixel size, for the conversion to length units
%
% Output
%  ps - @pairShifts, as fRunDIC returned
%  T  - @spatialTransform, the same stage fitted
%
% Description
% Everything here is in PIXELS - the ROI centres, the displacements and so
% the fitted transform - and is converted to length units only when the
% @pairShifts is built, exactly as fRunDIC did.
%
% The transform is fitted in the SHIFT convention rather than as a map from
% one frame to the other: T.eval(p) - p is the shift to apply at p, which is
% what remapShifted consumes and what pairShifts stores. Fitting it the other
% way round is a sign flip away and belongs with retiring @pairShifts.
%
% See also
% trueEbsd2/calcDistortion xcfShift spatialTransform

% The peak upsampling is not a user setting - 250 is a resolution, not a
% trade off anybody tunes, and xcfShift's own default is the same.
%
% numROI is one number: xcfShift scales the count down the image by the
% aspect ratio, which is the arithmetic every caller used to do by hand.
[u,peak,posROI] = xcfShift(imRef,imTest, ...
  'ROISize',xcf.ROISize,'numROI',xcf.NumROI);

% xcfShift reports the displacement from the first image to the second; the
% shift a stage fits is the other way round
shift = -u;

% drop the tiles that did not correlate, as every fit here would anyway
keep = isfinite(peak) & isfinite(shift.x) & isfinite(shift.y);

posK = posROI(keep); shiftK = shift(keep); w = peak(keep);

T = fitPrototype(proto,posK,posK + shiftK,w);

% the fitted field, at every pixel and at the tile centres
[X,Y] = meshgrid(1:size(imRef,2),1:size(imRef,1));
posPix = vector3d(X,Y,zeros(size(X)));

uMap = displacement(T,posPix);
uROI = displacement(T,posROI);

pix2um = @(d,v) d*v;

ps = pairShifts( ...
  pix2um(dx,uMap.x), pix2um(dy,uMap.y), ...
  pix2um(dx,uROI.x), pix2um(dy,uROI.y), ...
  pix2um(dx,shift.x), pix2um(dy,shift.y), ...
  posROI.x, posROI.y, xcf.ROISize, dx, dy);

end

% =========================================================================
function T = fitPrototype(proto,posA,posB,w)
% fit whichever stage this is, weighted the way fRunDIC weighted it
%
% Not every fit took the correlation peak as a weight: the projective and the
% drift spline went in unweighted, the drift because one median per scan line
% leaves nothing for a weight to outvote. Kept as it was, so that the only
% thing changing here is the solver.

switch class(proto)

  case 'spatialTransformShift'
    T = spatialTransformShift.fit(posA,posB,'weights',w);

  case 'spatialTransformRigid'
    T = spatialTransformRigid.fit(posA,posB,'weights',w);

  case 'spatialTransformPoly'
    T = spatialTransformPoly.fit(posA,posB,'degree',proto.degree,'weights',w);

  case 'spatialTransformProjective'
    T = spatialTransformProjective.fit(posA,posB);

  case 'spatialTransformDrift'
    % rows of tiles share a y in pixel coordinates, which is the slow scan
    % direction of the common grid.
    %
    % 'extrapolate' because Curve Fitting's linearinterp continues its end
    % segments, which is what this replaces - measured, it returns no NaN at
    % all. @spatialTransformDrift defaults the other way, leaving the band
    % outside its knots undefined, and without this the top and bottom of
    % every map come back NaN and the resampling has no coordinates to work
    % from.
    T = spatialTransformDrift.fit(posA,posB,'slowScan',vector3d.Y,'extrapolate');

  case 'spatialTransformField'
    T = spatialTransformField.fit(posA,posB);

  otherwise
    error('MTEX:trueEbsd:noFit', ...
      '%s has no fit, so it cannot be a stage of a hop.',class(proto));

end

end
