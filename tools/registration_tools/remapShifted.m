function imgOut = remapShifted(posGrid,shifts,img,shiftdir,varargin)
% resample an image in the shifted frame of its registration partner
%
% Syntax
%   imgOut = remapShifted(pos,shifts,img,'test2ref')
%   imgOut = remapShifted(pos,shifts,img,'ref2test','backend','scattered')
%
% Input
%  pos      - @vector3d, position of every pixel, r*c
%  shifts   - @pairShifts, the displacement field to apply, in um. Anything
%             with xShiftsMap and yShiftsMap fields will do, which is how
%             undistort passes a displacement accumulated over several hops
%             without having to fabricate a @pairShifts for it.
%  img      - r*c*z numeric, image values. Every channel is resampled
%             through one mapping, so stacking things that travel together
%             - image channels and an @EBSD id map, say - is cheaper than
%             calling this once each.
%  shiftdir - 'test2ref' to add the shifts, 'ref2test' to subtract them
%
% Output
%  imgOut   - img resampled on pos, same r*c*z, NaN where pos falls outside
%             the shifted image
%
% Options
%  'backend', 'inverse'   - invert the displacement field and sample the
%                           image on a regular grid (default)
%  'backend', 'scattered' - scatter the shifted pixels and rebuild with
%                           scatteredInterpolant, as TrueEBSD <= 2.1.0 did
%
% Description
% Every pixel of img sits at pos and is measured to belong at pos + s, so
% the value at pos itself has to be interpolated from neighbours. The two
% backends answer that from opposite ends.
%
% 'scattered' takes the forward route: it treats the displaced pixels as a
% point cloud, triangulates it, and asks for the nearest one to each grid
% point. That is O(n log n) to build and a tree search per query, and both
% halves get slower than linearly as the image grows.
%
% 'inverse' takes the backward route. The displacement field is smooth by
% construction - it is whatever the distortion model fitted, an affine, a
% spline along the slow scan direction or a homography - so p -> p + s(p) is
% invertible and its inverse can be found per pixel by the fixed point
% iteration q <- p - s(q), evaluating s on the regular grid it is stored on.
% Three or four passes converge to well under a hundredth of a pixel for the
% displacement magnitudes registration deals with. Sampling img at q is then
% a plain index, so the whole thing is O(n) with no triangulation.
%
% The two agree on all but a few pixels in ten thousand - ties in the
% nearest neighbour lookup fall differently - and 'inverse' keeps a slightly
% wider border, because 'scattered' returns NaN outside the convex hull of
% the displaced points while 'inverse' returns NaN outside the image.
%
% If the fixed point iteration does not settle, the mapping is not
% invertible on this grid, which means the fitted distortion folds the image
% over itself. That is a broken registration rather than a hard case, so it
% warns and falls back to 'scattered' rather than returning a wrong answer.
%
% See also
% calcDistortion undistort pairShifts

backend = get_option(varargin,'backend','inverse',{'char'});

switch shiftdir
    case 'test2ref'
        sgn =  1;
    case 'ref2test'
        sgn = -1;
    otherwise
        error('trueEbsd:badShiftDir', ...
            'shiftdir is ''%s'', expected ''test2ref'' or ''ref2test''',shiftdir);
end

sx = sgn*shifts.xShiftsMap;
sy = sgn*shifts.yShiftsMap;

if ~isequal(size(sx),size(posGrid))
    error('trueEbsd:shiftSizeMismatch', ...
        'the shift field is %s but the pixel grid is %s', ...
        mat2str(size(sx)),mat2str(size(posGrid)));
end

if strcmpi(backend,'inverse')
    [imgOut,converged] = inverseRemap(posGrid,sx,sy,img);
    if converged, return; end
    warning('trueEbsd:remapNotInvertible', ...
        ['The fitted displacement field is not invertible on this grid - it ' ...
         'folds the image over itself. Falling back to the scattered ' ...
         'interpolant, but treat this hop''s registration as suspect.']);
end

imgOut = scatteredRemap(posGrid,sx,sy,img);

end

% -------------------------------------------------------------------------
function [imgOut,converged] = inverseRemap(posGrid,sx,sy,img)
% backward mapping on the regular grid

[nr,nc] = size(posGrid);
imgOut  = [];

% column and row pitch of the grid, so the shifts can be expressed in
% pixels. pixelSizeMatch lays pos out with meshgrid, so this is exact; a
% grid that is not regular has no inverse map to iterate and goes to the
% other backend.
dCol = posGrid.x(1,2) - posGrid.x(1,1);
dRow = posGrid.y(2,1) - posGrid.y(1,1);
if nc < 2 || nr < 2 || dCol == 0 || dRow == 0
    converged = false; return
end

sCol = sx./dCol;   % displacement in columns
sRow = sy./dRow;   % displacement in rows

% a NaN in the displacement field has no inverse either
if any(~isfinite(sCol),'all') || any(~isfinite(sRow),'all')
    converged = false; return
end

[C,R] = meshgrid(1:nc,1:nr);
Fc = griddedInterpolant(sCol,'linear','nearest');
Fr = griddedInterpolant(sRow,'linear','nearest');

% q <- p - s(q), starting from the first order guess q = p - s(p).
%
% Convergence is judged on how far q + s(q) still is from p, not on how much
% q moved, and only over the pixels whose preimage lands inside the image -
% outside it the interpolant extrapolates a constant, so the iterate settles
% into a small limit cycle rather than onto a point and the residual there
% never reaches zero.
%
% Two ways out, because both happen. A clean field converges geometrically
% and crosses TOL; a field with a border limit cycle plateaus above it, and
% that plateau is accepted as long as it is a fraction of a pixel. Neither
% tolerance is delicate: the answer is a nearest neighbour index, so it only
% moves for a preimage within TOL of a cell boundary, and TOL is three
% orders of magnitude below the plateau the second branch already tolerates.
% Failing both is the real signal - the fitted distortion folds the image
% over itself and has no inverse on this grid.
TOL     = 1e-4;
PLATEAU = 0.25;

qc = C - sCol;
qr = R - sRow;
converged = false;
resid = Inf;
for k = 1:20
    fc = Fc(qr,qc);
    fr = Fr(qr,qc);
    inside = qc >= 1 & qc <= nc & qr >= 1 & qr <= nr;
    if any(inside,'all')
        eC = qc + fc - C;
        eR = qr + fr - R;
        newResid = max(max(abs(eC(inside))),max(abs(eR(inside))));
    else
        newResid = 0;
    end
    stalled = newResid > 0.9*resid;
    resid   = newResid;
    if resid < TOL || (stalled && resid < PLATEAU)
        converged = true;
        break
    end
    qc = C - fc;
    qr = R - fr;
end
if ~converged
    warning('trueEbsd:remapResidual', ...
        'inverse mapping left a residual of %.3g pixels after %d iterations',resid,k);
    return
end

% nearest sample, and NaN wherever that falls outside the image
ci = round(qc);
ri = round(qr);
outside = ci < 1 | ci > nc | ri < 1 | ri > nr;
ci(outside) = 1;
ri(outside) = 1;
ix = ri + (ci-1)*nr;

imgOut = zeros(nr,nc,size(img,3));
for p = 1:size(img,3)
    chan = img(:,:,p);
    chan = chan(ix);
    chan(outside) = NaN;
    imgOut(:,:,p) = chan;
end

end

% -------------------------------------------------------------------------
function imgOut = scatteredRemap(posGrid,sx,sy,img)
% forward mapping through a Delaunay triangulation of the displaced pixels

xRemap = posGrid.x + sx;
yRemap = posGrid.y + sy;

imgOut = zeros(size(posGrid,1),size(posGrid,2),size(img,3));
for p = 1:size(img,3)
    chan = img(:,:,p);
    if p == 1
        F = scatteredInterpolant(xRemap(:),yRemap(:),chan(:),'nearest','none');
    else
        % the triangulation does not depend on the values, so reuse it
        F.Values = chan(:);
    end
    imgOut(:,:,p) = F(posGrid.x,posGrid.y);
end

end
