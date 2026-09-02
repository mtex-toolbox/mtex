function job = calcDistortion(job,varargin)
% fit the distortion separating every consecutive pair of maps
%
% Syntax
%   job = calcDistortion(job)
%   job = calcDistortion(job,'fitErr')
%
% Input
%  job - @trueEbsd, after pixelSizeMatch
%
% Output
%  job - the same @trueEbsd (a handle), with shifts and job.T fitted and,
%        under 'fitErr', fitError filled in
%
% Options
%  fitErr               - measure the residual displacement left after each
%                         hop is fitted and print it. This is the number
%                         that says whether registration worked, and it is
%                         also what the ROI retry below tests against, so
%                         without it every hop gets exactly one pass. It
%                         costs one extra cross correlation per hop.
%  silent               - do not print the progress table
%  retryMax             - maximum number of correlation attempts per hop
%                         (default 100, in practice unlimited). Each attempt
%                         after the first doubles the ROI width. Counts
%                         total attempts, not extra ones, so 1 means a
%                         single pass; values below 1 are clamped to 1.
%
% Description
% job.T(n) is the unfitted @spatialTransform separating map n from map n+1,
% and stageList expands it into the sequence of stages to fit. For every
% consecutive pair this divides the images into ROIs, cross correlates them
% to get a local shift per ROI, and fits the stages to those shifts, each
% one fitted on what the previous left over. The per stage measurements land
% in job.shifts{n} as @pairShifts, and job.T(n) is replaced by the fitted
% transform - still of the class it was declared as.
%
% The pairs are not visited in index order. Traversal starts at the first
% map flagged highContrast, runs forward to the reference, then runs
% backward from there to map 1, so that one map in every correlated pair has
% usable edge contrast. Where the other map does not, its partner's
% intensities are remapped into its frame and that remapped image, not the
% original, is what the next hop correlates against.
%
% ROI size is optimised by retry: a hop whose residual exceeds 2 pixels is
% redone with the ROI width doubled, until it converges or the ROI no longer
% fits the image.
%
% See also
% trueEbsd/pixelSizeMatch trueEbsd/undistort spatialTransform xcfShift

fitErr   = check_option(varargin,'fitErr');
verbose  = ~check_option(varargin,'silent');

% retryMax counts attempts, so it has to be at least one or nothing is
% calculated at all
retryMax = max(get_option(varargin,'retryMax',100),1);

nImg = numel(job.resizedList);
if nImg < 2
  error('MTEX:trueEbsd:tooFewImages','calcDistortion needs at least two maps');
end
if any(arrayfun(@(d) isempty(d.img),job.resizedList))
  error('MTEX:trueEbsd:noPositions', ...
    'job.resizedList is empty - run pixelSizeMatch first');
end
if numel(job.T) ~= nImg-1
  error('MTEX:trueEbsd:modelCount', ...
    ['%d maps means %d hops, but job.T has %d entries. Set one '...
    'unfitted @spatialTransform per hop, spatialTransformId where '...
    'nothing separates a pair.'],nImg,nImg-1,numel(job.T));
end

% What each map contributes to the correlation - the edge transform, or the
% raw values where the two images already share contrast. Computed once for
% the whole run: edgeMap normalises and differences the whole image, which at
% map size costs more than the correlation it feeds.
% Anything left at 'auto' is measured here, once, from a cheap coarse
% correlation - and what was chosen is reported, because automation that
% cannot be audited is worse than a parameter. Settings given outright are
% used untouched and nothing is measured for them.
[job.opt,regImg,autoNotes] = autoTune(job);

% -- output --------------------------------------------------------------
job.shifts = cell(1,nImg-1);
if fitErr
  job.fitError = createArray(nImg-1,1,'pairShifts');
end

% -- traversal order -----------------------------------------------------
% start at the first map with usable edge contrast, walk forward to the
% reference, then walk backward from the start down to map 1
nStart = find([job.opt.highContrast],1,'first');
if isempty(nStart), nStart = 1; end

chainAt = '';

% the table columns, as widths, so the rule and the rows cannot drift apart
% from the header
colw = [12 13 8 18 18];

sayAuto(autoNotes)
sayHeader

% the image handed on from one hop to the next: whichever side of the pair
% had poor contrast gets its partner's intensities remapped into its frame,
% and that is what the following hop correlates. Empty means "use the map's
% own image".
carry = [];
for n = nStart:nImg-1
  carry = runHop(n,true,carry);
end

carry = [];
for n = nStart-1:-1:1
  carry = runHop(n,false,carry);
end

sayFooter

%% ------------------------------------------------------------------------
  function carryOut = runHop(n,isForward,carryIn)
    % measure one hop, retrying with a bigger ROI until it converges
    %
    % isForward says which side of the pair the incoming remapped image
    % belongs to: going forward the test image is the one being carried,
    % going backward it is the reference. Everything else is the same in
    % both directions, which is why there is one body rather than two.

    test = job.resizedList(n);
    ref  = job.resizedList(n+1);

    % lengths into the pixel units the correlation works in, one entry
    % per fit stage - a scalar roiSize applies to every stage
    xcf = roiSettings(job.opt(n),test.dx);

    imTest0 = regImg{n};
    imRef0  = regImg{n+1};
    if ~isempty(carryIn)
      if isForward, imTest0 = carryIn; else, imRef0 = carryIn; end
    end

    stages   = stageList(job.T(n));
    nStage   = numel(stages);
    isTrue   = nStage == 0;
    carryOut = [];

    sayFrom(n)

    for attempt = 1:retryMax

      imTest = imTest0;
      job.shifts{n} = createArray(max(nStage,1),1,'pairShifts');
      fitted = spatialTransform.empty;

      % the distortion names the hop, so it sits on the hop's first
      % row only and the rest of the block reads as one thing
      dist = shortChar(job.T(n));

      if isTrue
        % nothing separates this pair, so there is nothing to correlate
        sayRow(dist,'·','·',pxStr([0 0 0]),'');
        dist = '';
      else
        % stack the distortion models, each fitted on the residual
        % the previous one left
        for m = 1:nStage
          k = min(numel(xcf),m);
          job.shifts{n}(m) = measureShift(ref,imRef0,test,imTest,xcf(k));
          fitted(m) = fitTo(stages(m),job.shifts{n}(m));

          % the FITTED stage, because that is what knows its own
          % degree - an unfitted poly cannot say whether it is a
          % poly11 or a poly22
          sayRow(dist,shortChar(fitted(m)), ...
            sprintf('%d px',xcf(k).ROISize), ...
            pxStr(meanShift(job.shifts{n}(m),test.dx)),'');
          dist = '';

          % the test image corrected by this stage, for the next to be
          % fitted on what it leaves
          imTest = resample(test,imTest,inv(fitted(m)));
        end

        % the hop's transform, now fitted, and still the class it
        % was declared as - a fitted tilt that came back a composite
        % would lose the name of the model it stands for. stages came
        % off the prototype before the attempt loop, so a retry
        % refits from the same declaration, not from its own answer
        job.T(n) = refitted(job.T(n),fitted);
      end

      % hand the well-contrasted image on to the next hop, in the
      % frame of the poorly-contrasted one
      if isForward && ~job.opt(n+1).highContrast
        carryOut = imTest;
      elseif ~isForward && ~job.opt(n).highContrast
        carryOut = resample(ref,imRef0,job.T(n));
      end

      % Residual shifts. Not used downstream - this is the measure of
      % how well the hop registered, and the only thing a retry can be
      % decided on, which is why there is no retry without it.
      if ~fitErr, break; end

      job.fitError(n) = measureShift(ref,imRef0,test,imTest,xcf(end));

      residPix = meanShift(job.fitError(n),test.dx);

      % on an identity hop nothing was fitted, so the number is not a
      % fit error - it is what the pair happens to differ by, and the
      % retry below ignores it. Different name, different meaning.
      if isTrue, what = '↳ difference'; else, what = '↳ residual'; end
      sayRow(dist,what,'','',pxStr(residPix));

      if isTrue || residPix(1) <= 2, break; end

      [xcf,grown] = growROI(xcf,nStage,gridSize(test));
      if ~grown, break; end
      job.opt(n).roiSize = [xcf.ROISize]*test.dx;
    end

    sayTo(n+1)
  end

%% ------------------------------------------------------------------------
  function [xcf,grown] = growROI(xcf,nStage,imSize)
    % double the ROI width once per stage entry, unless it stops fitting
    %
    % Stage m reads xcf(min(numel(xcf),m)), so several stages usually
    % share one entry - the normal case is a single entry serving them
    % all. Looping over stages therefore used to double the same entry
    % once per stage, quadrupling a two stage hop's ROI per retry and
    % skipping the size in between. Loop over the entries instead.
    %
    % Still the backstop even with roiSize measured up front: the coarse
    % pass can under-read a shift, and this is what catches that.

    grown = true;
    for k = 1:min(numel(xcf),nStage)
      newSize = 2*xcf(k).ROISize;
      maxSize = min(imSize(2)-xcf(k).NumROI,imSize(1)-xcf(k).NumROI);
      if newSize >= maxSize
        sayNote(sprintf(['⚠ residual over 2 px, but a %d px ROI does ' ...
          'not fit the image — keeping this fit'],newSize));
        grown = false;
        return
      end
      xcf(k).ROISize = newSize;
    end
    sayNote(sprintf('↻ residual over 2 px, retrying with a %d px ROI', ...
      xcf(1).ROISize));
  end

%% ------------------------------------------------------------------------
% Progress reporting. One row per fit stage as it completes, so a long run
% says what it is doing rather than going quiet, and the whole thing still
% reads as a table afterwards. The residual arrives after the last stage of
% a hop, so it gets its own row rather than being held back.
%
% The left hand column is the sequence itself, drawn as a spine: each hop
% names the map it starts from (●), the rows of that hop hang off it (│),
% and the arrow (▼) lands on the map the next hop starts from. So the chain
% reads down the page in the order the maps are actually corrected, and a hop
% that jumps - the backward pass does - shows up as a break in the spine
% rather than silently reading as though it followed on.
%
% The marks are all BMP text-presentation characters, so they stay one column
% wide in a terminal: ◆ section, ● map, │ hop body, ▼ hop, ↳ summary of the
% hop above, ↻ retry, ⚠ gave up retrying, · not applicable.
%
% shift and residual are each a length and the signed x and y behind it, see
% pxStr - how far the hop moved, and which way.

  function sayHeader
    if ~verbose, return; end
    fprintf('\n ◆ distortion across %d maps, %d hops\n\n',nImg,nImg-1);
    fprintf('    %s\n',rowStr({'distortion','stage','ROI','shift, px','residual, px'}));
    fprintf('    %s\n',rowStr(arrayfun(@(w) repmat('─',1,w),colw, ...
      'UniformOutput',false)));
  end

  function s = rowStr(c)
    % one table row, left aligned on the two label columns and right
    % aligned on the three numeric ones
    s = '';
    for k = 1:numel(c)
      if k <= 2, pad = '-'; else, pad = ''; end
      s = [s sprintf(['%' pad num2str(colw(k)) 's '],c{k})]; %#ok<AGROW>
    end
    s = deblank(s);
  end

  function sayFooter
    if ~verbose, return; end
    fprintf('\n');
  end

  function sayFrom(n)
    % the map a hop starts from, unless the spine is already there
    if ~verbose, return; end
    if strcmp(chainAt,nameOf(n)), return; end
    if ~isempty(chainAt), fprintf('\n'); end   % a jump, not a step
    fprintf('  ● %s\n',nameOf(n));
    chainAt = nameOf(n);
  end

  function sayTo(n)
    % the map a hop lands on, which the next hop starts from
    if ~verbose, return; end
    fprintf('  ▼\n  ● %s\n',nameOf(n));
    chainAt = nameOf(n);
  end

  function s = nameOf(n)
    % what undistort writes this map's image under
    s = char(job.resizedList(n).name);
  end

  function sayRow(dist,stage,roi,shift,resid)
    if ~verbose, return; end
    fprintf('%s\n',deblank(sprintf('  │ %s', ...
      rowStr({dist,stage,roi,shift,resid}))));
  end

  function sayNote(txt)
    if ~verbose, return; end
    fprintf('  │ %s\n',txt);
  end

  function sayAuto(a)
    % what was measured rather than given, as two rows of numbers. It is
    % the audit trail for the automatic settings, so it goes above the
    % table rather than inside it - these are not hops.
    if ~verbose, return; end
    if ~any(isfinite([a.edgePx a.roiPx])), return; end

    fprintf('\n ◆ measured settings, override with setOptions\n');
    if any(isfinite(a.edgePx))
      fprintf('   ▸ edgeWidth  per map  %s px\n',vecStr(a.edgePx,0));
    end
    if any(isfinite(a.roiPx))
      fprintf('   ▸ roiSize    per hop  %s px   ← shifts %s px, features %s px\n', ...
        vecStr(a.roiPx,0),vecStr(a.shiftPx,1),vecStr(a.featPx,0));
    end
  end

end

%% =========================================================================
function xcf = roiSettings(opt,px)
% the flat, length valued settings as one pixel valued struct per fit stage

roi = max(round(opt.roiSize(:).'/px),0);
roi = 2*round(roi/2);   % the correlation wants an even tile

xcf = struct('ROISize',num2cell(roi),'NumROI',opt.numROI);

end

%% =========================================================================
function T = refitted(proto,fitted)
% the fitted stages, in the class the hop was declared as

if isa(proto,'spatialTransformComposite')
  T = proto; T.stages = fitted;
else
  T = fitted;
end

end

%% =========================================================================
function s = vecStr(v,dec)
% a row of numbers for a note line, '·' where nothing was measured because
% the value was given outright

c = cell(1,numel(v));
for k = 1:numel(v)
  if isnan(v(k)), c{k} = '·'; else, c{k} = sprintf('%.*f',dec,v(k)); end
end
s = strjoin(c,' ');

end

