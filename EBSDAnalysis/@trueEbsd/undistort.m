function job = undistort(job)
% resample every map onto the reference grid, correcting its distortion
%
% Syntax
%   job = undistort(job)
%
% Input
%  job - @trueEbsd, after calcDistortion
%
% Output
%  job - the same @trueEbsd (a handle), with undistortedList filled in
%
% Description
% calcDistortion fitted the transform of each consecutive pair, so the
% correction for one map is the composition of every hop between it and
% the reference, its own hop first. The reference itself does not move.
% Afterwards every map is on the reference grid and every pixel overlays.
%
% Every aligned image is then written into the properties of every map in
% the sequence that carries an @EBSD, under that map's name - ebsd.fsd1a,
% or ebsd.img2 for an entry constructed without a 'name'. Map and image are
% in one array order by then, so this is a plain assignment and a multi
% channel image stays r × c × k. That is what makes an image usable as a
% per pixel property of the map: it survives gridify, indexing and subGrid
% along with everything else the map carries.
%
% Resampling is nearest neighbour throughout. For images that is a choice -
% linear or cubic would work and would be smoother - but nearest neighbour
% is least likely to invent intensities that were never measured. For an
% @EBSD map it is not a choice: orientations and phase labels have no
% meaningful in-between.
%
% See also
% calcDistortion pixelSizeMatch spatialTransform

nImg = numel(job.resizedList);
if numel(job.shifts)+1 ~= nImg
  error('MTEX:trueEbsd:shiftsMissing', ...
    ['job has %d maps but %d hops of shifts - run calcDistortion first, ' ...
    'or check that it completed'],nImg,numel(job.shifts));
end

% start from the resized maps and overwrite what moves
job.undistortedList = job.resizedList;

% the transform from map n to the reference, its own hop first
T = spatialTransformId;

for n = nImg-1:-1:1

  T = T * job.T(n);
  mg = job.resizedList(n);

  % for each pixel of the common grid, ask where it came from
  src = eval(inv(T),mg.pos);

  job.undistortedList(n).img = interp(mg,src,'nearest');

  if ~isempty(mg.ebsd)
    ebsd = interp(mg.ebsd,src(:));
    ebsd.pos = mg.ebsd.pos(:);
    job.undistortedList(n).ebsd = gridify(ebsd,mg.layout);
  end

end

% Every map is now on the reference grid, so every aligned image is a
% per pixel property of every map that carries an @EBSD - which is the whole
% point of the alignment. Map and image share one array order, so this is a
% plain assignment, and the image then travels with the map through gridify,
% indexing and subGrid like any other property.
for n = 1:nImg
  if isempty(job.undistortedList(n).ebsd), continue; end
  ebsdOut = job.undistortedList(n).ebsd;
  for m = 1:nImg
    fn = job.undistortedList(m).name;
    if isfield(ebsdOut.prop,fn)
      warning('MTEX:trueEbsd:propOverwritten', ...
        ['map %d already carries a property ''%s'' - the aligned ' ...
        'image of map %d is overwriting it. Give that map a ' ...
        'distinct ''name'' to keep both.'],n,fn,m);
    end
    ebsdOut.prop.(fn) = job.undistortedList(m).img;
  end
  job.undistortedList(n).ebsd = ebsdOut;
end

end
