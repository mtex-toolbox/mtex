function job = undistort(job,varargin)
% resample every map onto the reference grid, correcting its distortion
%
% Syntax
%   job = undistort(job)
%   job = undistort(job,'backend','scattered')
%
% Input
%  job - @trueEbsd, after calcDistortion
%
% Output
%  job - the same @trueEbsd (a handle), with undistortedList filled in
%
% Options
%  backend - 'inverse' (default) or 'scattered', see remapShifted. 'inverse'
%            is the fast one; 'scattered' is what TrueEBSD <= 2.1.0 ran, for
%            reproducing older numbers.
%
% Description
% calcDistortion measures the displacement between each consecutive pair, so the
% correction for one map is the sum of every hop between it and the
% reference. Those stack in reverse: job.undistortedList(1) is shifted by
% everything in job.shifts, job.undistortedList(2) by job.shifts{2:end}, and
% the reference is not shifted at all. Afterwards every map is on the same
% grid and every pixel overlays.
%
% Afterwards every aligned image is also written into the properties of
% every map in the sequence that carries an @EBSD, under that map's name -
% ebsd.fsd1a, or ebsd.img2 for an entry constructed without a 'name'. Map and
% image are in one array order by then, so this is a plain assignment and a
% multi channel image stays r x c x k. That is what makes an image usable as a
% per pixel property of the map: it survives gridify, indexing and subGrid
% along with everything else the map carries.
%
% Resampling is nearest neighbour throughout. For images that is a choice -
% linear or cubic would work and would be smoother - but nearest neighbour
% is least likely to invent intensities that were never measured.
%
% For @EBSD data it is not a choice. Orientations and phase labels have no
% meaningful in-between, so what gets resampled is the map's id: the id
% travels through exactly the same mapping as the image, and the output map
% is rebuilt by looking up each resampled id in the input map. Note that
% EBSDsquare/interp is not usable here - it assumes a regular grid, and the
% whole point of this step is that the input is not on one.
%
% See also
% calcDistortion pixelSizeMatch remapShifted

backend = get_option(varargin,'backend','inverse',{'char'});

nImg = numel(job.resizedList);
if numel(job.shifts)+1 ~= nImg
    error('MTEX:trueEbsd:shiftsMissing', ...
        ['job has %d maps but %d hops of shifts - run calcDistortion first, ' ...
         'or check that it completed'],nImg,numel(job.shifts));
end

% start from the resized maps and overwrite what moves
job.undistortedList = job.resizedList;

% Displacement accumulated from the reference back to the current map. The
% loop runs in reverse so each map picks up its own hop on top of every hop
% downstream of it.
%
% The base is the reference map's grid, which is what the shifts are
% expressed against; any difference between that and the current map's own
% grid rides along in the same field. After pixelSizeMatch the two are the
% same grid and the difference is identically zero, but stating it costs
% nothing and keeps this correct if that ever stops being true.
posRef = imageGrid(job.resizedList(end));
sx = zeros(size(posRef));
sy = zeros(size(posRef));

for n = nImg:-1:1

    if n < nImg
        for m = 1:numel(job.shifts{n})
            sx = sx + job.shifts{n}(m).xShiftsMap;
            sy = sy + job.shifts{n}(m).yShiftsMap;
        end
    end

    pos = imageGrid(job.resizedList(n));
    shifts = struct('xShiftsMap',sx + (posRef.x - pos.x), ...
                    'yShiftsMap',sy + (posRef.y - pos.y));

    if ndims(job.resizedList(n).img) > 3
        error('MTEX:trueEbsd:image4D','can''t handle 4D images');
    end

    % The image channels and, where there is one, the map's id all go
    % through the same resampling, so they travel as one stack and the
    % mapping is worked out once.
    stack   = job.resizedList(n).img;
    nChan   = size(stack,3);
    ebsdIn  = job.resizedList(n).ebsd;
    hasEbsd = ~isempty(ebsdIn);
    % the map is stored in the same array order as its image, so its ids can
    % be stacked on top and travel through the resampling with the channels
    if hasEbsd
        stack = cat(3,stack,double(ebsdIn.id));
    end

    stack = remapShifted(pos,shifts,stack,'test2ref','backend',backend);

    job.undistortedList(n).img = stack(:,:,1:nChan);

    % the last map is the reference and comes back unchanged, which is why
    % numel(job.shifts)+1 == numel(job.resizedList)

    if hasEbsd
        job.undistortedList(n).ebsd = rebuildMap(ebsdIn,stack(:,:,nChan+1));
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
        fn = imgName(job.undistortedList(m),m);
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

%% =========================================================================
function name = imgName(disImg,n)
% the property name an aligned image is written under

name = disImg.name;
if isempty(name), name = sprintf('img%d',n); end

end

%% =========================================================================
function ebsdOut = rebuildMap(ebsdIn,newId)
% build a map whose point k holds whatever input point newId(k) held
%
% Everything is read straight out of the map-shaped arrays rather than by
% indexing the @EBSD object once per property. The two are equivalent -
% ebsdIn(id).prop.bc is ebsdIn.prop.bc(id) - but building eight @EBSD
% subsets of the whole map costs twenty times what indexing the arrays does.

ix  = ~isnan(newId) & newId > 0;   % nearest-neighbour misses land outside
src = newId(ix);

blank = zeros(ebsdIn.size);

prop = ebsdIn.prop;
for fn = fieldnames(prop)'
    v = ebsdIn.prop.(char(fn));
    prop.(char(fn))     = blank;
    prop.(char(fn))(ix) = v(src);
end

rot      = rotation.nan(ebsdIn.size);
rot(ix)  = ebsdIn.rotations(src);

phase     = blank;
phase(ix) = ebsdIn.phase(src);

% Flatten to one point per row: the @EBSD constructor expects that, and
% MTEX 7's gridify hangs on a map-shaped @EBSD rather than rejecting it.
% gridify below restores the r*c shape.
prop  = structfun(@(v) v(:),prop,'UniformOutput',false);
ebsd1 = EBSD(ebsdIn.pos(:),rot(:),phase(:),ebsdIn.CSList,prop);

% The positions come straight from the resized map and carry its reference
% frame with them, and gridify keeps it, so the alignment needs no restating.
% The layout does have to be restated: without it gridify would canonicalise
% the map to d1 along y and it would stop matching the image it aligns with.
ebsdOut = gridify(ebsd1,ebsdIn.layout);

end
