classdef trueEbsd2 < handle
    % @trueEbsd2 class constructor
    % class guiding through the trueEBSD image correction process
    %
    % A handle class, as every class guiding through a process in MTEX is -
    % see @parentGrainReconstructor. The workflow methods still return the
    % job, so
    %
    %   job = pixelSizeMatch(job,pixSz)
    %
    % reads and behaves the same as before; the difference is that the job
    % is now modified in place, so forgetting the assignment no longer
    % silently does nothing. Two consequences worth knowing: a second
    % variable holding the job refers to the same object rather than to a
    % snapshot, and a method that errors part way through leaves the job
    % partly filled instead of leaving the caller's copy untouched.
    %
    % Syntax
    %
    %   job = trueEbsd2(imgList)
    %   job = trueEbsd2(imgList,T)
    %
    % Input
    %  imgList - @mapImage array, ordered from the most distorted map
    %            imgList(1) to the ground truth imgList(end). One array
    %            argument, not one argument per map. An EBSD map joins the
    %            sequence as mapImage(ebsd.bc,ebsd) - an image, with the map
    %            riding along
    %  T       - @spatialTransform array, one per hop, so numel(T) is
    %            numel(imgList)-1. Unfitted prototypes: the class says which
    %            distortion separates the pair, calcDistortion fills in the
    %            coefficients. May also be set afterwards as job.T
    %
    % Output
    %  job - @trueEbsd2
    %
    % Class Properties
    %  imgList         - @mapImage array, as imported: differing pixel sizes
    %                    and extents
    %  T               - @spatialTransform array, one per hop. THE MODEL IS
    %                    THE CLASS - see below
    %  resizedList     - @mapImage array, every map on one common pixel
    %                    grid. Filled by pixelSizeMatch
    %  shifts          - cell, one entry per hop, each a @pairShifts array
    %                    with one entry per fit stage - the last being the
    %                    final fit. Filled by calcDistortion
    %  fitError        - @pairShifts array, one per hop: the residual shifts
    %                    measured *after* correction, which is the
    %                    diagnostic saying whether registration worked.
    %                    Filled by calcDistortion with the 'fitErr' flag
    %  undistortedList - @mapImage array, aligned: every pixel of every map
    %                    directly overlayable. Filled by undistort
    %  opt             - struct array, one per map: the registration
    %                    settings that are a fact about the job rather than
    %                    about the image. Set them with setOptions rather
    %                    than by hand - see trueEbsd2/setOptions
    %
    % The model is the class
    %
    % A hop's distortion used to be a string on the map before it, expanded
    % by a switch into a list of fit functions. It is now an unfitted
    % @spatialTransform, one per hop, and the class IS the model:
    %
    %   job.T = [spatialTransformShift + spatialTransformDrift, ...
    %            spatialTransformId, ...
    %            spatialTransformShift, ...
    %            spatialTransformTilt];
    %
    % A multi stage hop is +, never *: mtimes absorbs an operand that
    % reports isid, and an unfitted prototype has zero coefficients and so
    % reports exactly that, which would leave hop 1 above a bare drift with
    % the shift silently gone. + keeps both stages.
    %
    % Three things follow. Parameters travel with the model, where a string
    % could not carry them - spatialTransformDrift('slowScan',xvector) says
    % which way the beam scanned. The old 'shift-drift' and 'drift-shift'
    % stop being names anything is constructed from and become the order the
    % stages are written in - they survive only as labels the GUI menu
    % offers, which is transformRegistry. And there is no 'true' sentinel on
    % the reference: there are numel(imgList)-1 hops and that many entries in
    % T, with spatialTransformId where nothing separates a pair.
    %
    % Indexing
    %
    %   job.opt(n)              % the settings for map n
%   job.imgList(n)          % @mapImage
    %   job.T(n)                % @spatialTransform, hop n
    %   job.shifts{n}(m)        % hop n, fit stage m
    %   job.fitError(n)         % @pairShifts
    %
    % and numel(job.T) == numel(job.imgList) - 1.
    %
    % See also
    % mapImage spatialTransform pairShifts trueEbsd2/pixelSizeMatch
    % trueEbsd2/calcDistortion trueEbsd2/undistort parentGrainReconstructor
    %

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
        function job = trueEbsd2(imgListIn,T)
            % a handle class has to be constructible without arguments,
            % for trueEbsd2.empty and for preallocation
            if nargin == 0, return; end

            job.imgList = argin_check(imgListIn,{'mapImage'});
            job.imgList = shareOneFrame(job.imgList);
            shareOneUnit(job.imgList);

            job.opt = defaultOptions(job.imgList);

            if nargin >= 2
                job.T = T;
            else
                % nothing said about any hop yet, so nothing is assumed -
                % calcDistortion refuses rather than guessing a model
                job.T = repmat(spatialTransform.empty,1,0);
            end

        end % constructor function

        function set.T(job,T)

            if isempty(T), job.T = spatialTransform.empty; return; end

            T = argin_check(T,{'spatialTransform'});

            % the constructor assigns imgList first, so it is populated by
            % the time this runs
            n = numel(job.imgList); %#ok<MCSUP>
            assert(n == 0 || numel(T) == n-1, ...
                'trueEbsd:modelCount', ...
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
  error('trueEbsd:unitMismatch', ...
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
    error('trueEbsd:frameMismatch',...
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
