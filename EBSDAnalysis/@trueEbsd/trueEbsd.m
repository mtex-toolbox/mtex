classdef trueEbsd < handle
% align a sequence of images and EBSD maps of one specimen area
%
% Two pictures of the same area rarely overlay: the EBSD map is taken at a
% tilt and drifts as it scans, the electron images do not, and no single
% distortion relates the extremes. TrueEBSD relates them through a CHAIN of
% intermediate maps instead, each pair separated by one distortion simple
% enough to fit, and composes the hops. What comes out is one common grid on
% which every pixel of every map is the same piece of specimen, so an image
% becomes a per pixel property of the map.
%
% The sequence is ordered from the most distorted map to the ground truth,
% and hop n separates imgList(n) from imgList(n+1). Three methods walk it:
% pixelSizeMatch puts every map on one grid, calcDistortion measures and fits
% each hop, undistort accumulates the hops and resamples.
%
% A handle class, as every class guiding a process in MTEX is - see
% @parentGrainReconstructor. The methods still return the job, so
% job = pixelSizeMatch(job,pixSz) reads as before, but the job is modified in
% place: a second variable holding it is an alias rather than a snapshot, and
% a method that errors part way leaves the job partly filled.
%
% THE MODEL IS THE CLASS. A hop's distortion is an unfitted
% @spatialTransform - the class names which distortion separates the pair and
% calcDistortion fills in the coefficients. A multi stage hop is written with
% + and never *, because mtimes absorbs an operand reporting isid and an
% unfitted prototype has zero coefficients, so * would silently drop a stage.
% There is no sentinel on the reference: where nothing separates a pair, the
% entry is spatialTransformId.
%
% Syntax
%
%   job = trueEbsd(imgList)
%   job = trueEbsd(imgList,T)
%
%   imgList = [mapImage(ebsd.bc,ebsd), mapImage(img,'dxy',0.05)]
%   job = trueEbsd(imgList, spatialTransformShift + spatialTransformDrift)
%   job.pixelSizeMatch
%   job.calcDistortion('fitErr')
%   job.undistort
%
% Input
%  imgList - @mapImage array, most distorted first, ground truth last. One
%            array, not one argument per map. An EBSD map joins the sequence
%            as mapImage(ebsd.bc,ebsd) - an image, with the map riding along
%  T       - @spatialTransform array, one per hop, numel(imgList)-1 of them.
%            Unfitted prototypes. May also be set afterwards as job.T
%
% Output
%  job - @trueEbsd
%
% Class Properties
%  imgList         - @mapImage array as imported, differing pixel sizes and
%                    extents
%  T               - @spatialTransform array, one per hop
%  resizedList     - @mapImage array on one common pixel grid, filled by
%                    pixelSizeMatch
%  shifts          - cell, one entry per hop, each a @pairShifts array with
%                    one entry per fit stage: the shifts that stage was
%                    fitted to
%  fitError        - @pairShifts array, one per hop: the shifts measured
%                    AFTER correction, which is what says whether
%                    registration worked. Needs the 'fitErr' flag
%  undistortedList - @mapImage array, aligned, filled by undistort
%  opt             - struct array, one per map, the registration settings.
%                    Set with setOptions rather than by hand
%
% Indexing, with numel(job.T) == numel(job.imgList) - 1
%
%   job.imgList(n)          % @mapImage
%   job.T(n)                % @spatialTransform, hop n
%
% job.T is a sequence and every @spatialTransform method takes one transform,
% so inv(job.T) and isid(job.T) do not work - index a hop, or fold the chain
% with *. See @spatialTransform and docs/adr/0007.
%   job.opt(n)              % the settings for map n
%   job.shifts{n}(m)        % hop n, fit stage m
%   job.fitError(n)         % @pairShifts
%
% References
%
% Tong et al., TrueEBSD in MTEX: automatic image matching for correlative
% microscopy applications, <https://arxiv.org/abs/2605.00703 arXiv 2605.00703>
%
% See also
% mapImage spatialTransform pairShifts trueEbsd/pixelSizeMatch
% trueEbsd/calcDistortion trueEbsd/undistort trueEbsd/setOptions
% parentGrainReconstructor

  properties % one per workflow stage
    imgList = mapImage.empty % as imported
    T = spatialTransform.empty % the distortion of each hop
    resizedList = mapImage.empty % pixel sizes and FOV matched
    undistortedList = mapImage.empty % aligned
    shifts = {} % cell, one entry per hop - see the class help
    fitError = pairShifts.empty % residuals measured after correction
    opt = struct.empty % per map registration settings
  end %properties

  methods
    % constructor
    function job = trueEbsd(imgListIn,T)
      % a handle class has to be constructible without arguments,
      % for trueEbsd.empty and for preallocation
      if nargin == 0, return; end

      job.imgList = argin_check(imgListIn,{'mapImage'});
      job.imgList = shareOneFrame(job.imgList);
      shareOneUnit(job.imgList);

      % the name an aligned image is written under, so every map has one
      for k = find(cellfun(@isempty,{job.imgList.name}))
        job.imgList(k).name = sprintf('img%d',k);
      end

      job.opt = defaultOptions(job.imgList);

      if nargin >= 2, job.T = T; end

    end % constructor function

    function set.T(job,T)

      if isempty(T), job.T = spatialTransform.empty; return; end

      T = argin_check(T,{'spatialTransform'});

      % the constructor assigns imgList first, so it is populated by
      % the time this runs
      n = numel(job.imgList); %#ok<MCSUP>
      assert(n == 0 || numel(T) == n-1, ...
        'MTEX:trueEbsd:modelCount', ...
        ['A %d map sequence has %d hops, so T needs %d entries, ' ...
        'got %d. Use spatialTransformId where nothing separates a ' ...
        'pair - the reference has no entry of its own.'], ...
        n,n-1,n-1,numel(T));

      job.T = T(:).';

    end

  end %methods

end %classdef

% =========================================================================
function opt = defaultOptions(imgList)
% the registration settings, one entry per map
%
% These describe how the job should register, not what an image is, so they
% live here rather than on @mapImage.
%
% Everything scale dependent defaults to 'auto' and is measured from a cheap
% coarse correlation the first time it is needed - there is no fixed value
% that is right for both a 20 um field of view and a 2 mm one. Anything set
% outright is used untouched and nothing is measured for it.
%
% roiSize and edgeWidth are lengths, in the sequence's scanUnit, so they mean
% the same thing before and after pixelSizeMatch and do not have to be
% restated when the grid changes. Both may be one value per fit stage; a
% scalar applies to every stage.

n = numel(imgList);

opt = repmat(struct( ...
  'roiSize','auto', ...       % length, per stage
  'numROI',24, ...            % tiles across; down follows the aspect ratio
  'registerOn','edge', ...    % 'edge' or 'raw'; see setOptions
  'edgeWidth','auto', ...     % length
  'highContrast','auto', ...  % true, false, or a measurement
  'pixelTime',0), 1, n);

end

% =========================================================================
function shareOneUnit(imgList)
% One job is one sample area, so every entry measures it in one unit.
%
% The same class of error as a frame mismatch and just as silent: a sequence
% mixing um and nm would resample, correlate and fit without complaint, and
% every length the job is given - roiSize, edgeWidth - would mean a different
% thing depending on which entry read it.

if numel(imgList) < 2, return; end

u = {imgList.scanUnit};
bad = find(~strcmp(u,u{1}),1);

if ~isempty(bad)
  error('MTEX:trueEbsd:unitMismatch', ...
    ['Image 1 is in %s and image %d is in %s, so no length given to the '...
    'job means the same thing to both. Put the sequence in one unit '...
    'before building it.'],u{1},bad,u{bad});
end

end

% =========================================================================
function imgList = shareOneFrame(imgList)
% One job is one sample area, so every entry has to be in one frame.
%
% Every entry in the sequence shows the same piece of sample - that is the
% premise of the whole workflow, and after undistort they overlay pixel for
% pixel - so two entries whose arrays are laid out along different directions
% are not comparable and nothing downstream can make them so. Cross
% correlation would still run, still fit, and still return a finished looking
% job full of noise.
%
% Where the arrays sit relative to each other is not derivable from them, so
% it is not guessed here: it is stated, by transformReferenceFrame, before
% the job is built. This is the check that it was.
%
% The comparison is on the layout - which way round each array is stored -
% and not on frame or how2plot. Those say where the data lives and how it is
% drawn, which are different questions: two entries can share a specimen
% frame and still be stored a quarter turn apart.

if numel(imgList) < 2, return; end

ref = imgList(1).layout;

for k = 2:numel(imgList)

  gL = imgList(k).layout;

  if isempty(ref) || isempty(gL) || ~isAligned(gL,ref)
    error('MTEX:trueEbsd:frameMismatch',...
      ['Images %d and %d are stored along different directions, so they '...
      'cannot be compared pixel by pixel.\n'...
      '  image 1: rows run %s, columns run %s\n'...
      '  image %d: rows run %s, columns run %s\n'...
      'Bring them into one frame first, with transformReferenceFrame.'],...
      1,k,char(ref.basis(1)),char(ref.basis(2)),...
      k,char(gL.basis(1)),char(gL.basis(2)));
  end

end

end
