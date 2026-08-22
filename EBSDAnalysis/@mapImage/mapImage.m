classdef mapImage
% an image that knows where on the specimen it sits
%
% A raster of values - a forescatter or backscatter image, a band contrast
% map, any per pixel quantity - together with the geometry that says which
% part of the specimen each pixel covers. That is what makes an image and an
% EBSD map comparable objects rather than an array plus a pixel size and a
% convention held in someone's head.
%
% The grid is REGULAR: an origin and two perpendicular step vectors, with
% pos derived rather than stored. This is the difference from @EBSDgrid,
% which stores pos per pixel so that a measured grid may be rotated, sheared
% or smoothly distorted. An image is none of those - a distortion is applied
% by resampling onto a new regular grid, never by moving grid points - so
% the general contract would only mean permitting states that cannot arise.
%
% An EBSD map joins a sequence of images as one of them, carrying the map
% along with whichever channel is to be registered on:
%
%   mapImage(ebsd.bc,ebsd)
%
% so a whole sequence is one @mapImage array rather than a list of two
% different things.
%
% An image pre-processed for registration - gamma compressed, filtered - is
% an entry of its own, with spatialTransformId as the transform between it
% and the image it was derived from. Nothing here declares what to register
% on: that is a fact about a comparison, so it belongs to the job.
%
% Syntax
%
%   mg = mapImage(img)                        % unit step, its own frame
%   mg = mapImage(img,'dxy',0.05)             % square pixels
%   mg = mapImage(img,'dxy',[dx dy])
%   mg = mapImage(ebsd.bc,ebsd)               % a channel of a gridded map
%   mg = mapImage(img,ebsd)                   % an image already on the map's grid
%   mg = mapImage(img,'dxy',0.05,'name','bse')
%
% Input
%  img  - r x c x k numeric, integer types scaled to [0,1]
%  ebsd - @EBSD, gridded and square
%
% Output
%  mg - @mapImage
%
% Options
%  dxy    - pixel size, scalar or [dx dy]
%  name   - a valid MATLAB identifier, the field an aligned image is written under
%  origin - @vector3d position of pixel (1,1)
%
% Class Properties
%  img        - r x c x k values
%  name       - what this image is called
%  ebsd       - @EBSD on the same grid, empty if there is none
%  origin     - @vector3d, the position of pixel (1,1)
%  d1, d2     - @vector3d, the step from row to row and column to column
%  frame      - @referenceFrame the geometry is expressed in
%  pos        - r x c @vector3d, derived from origin, d1 and d2
%  arrayFrame - @imageFrame the array is laid out in, derived from d2 and d1
%
% See also
% EBSD EBSDsquare imageFrame mapImage/interp mapImage/edgeMap

  properties
    img = []
    name = ''
    ebsd = EBSD    % default constructed, not EBSD.empty - isempty on an
                   % empty EBSD ARRAY errors inside phaseList
    origin = vector3d(0,0,0)
    d1 = vector3d(0,1,0)
    d2 = vector3d(1,0,0)
    frame = referenceFrame.empty
  end

  properties (Dependent = true)
    pos        % r x c @vector3d, one per pixel
    arrayFrame % @imageFrame the array is laid out in
    how2plot   % plotting convention - read only, carried by the frame
    dx         % column step length
    dy         % row step length
    nChannel   % size(img,3)
  end

  methods

    function mg = mapImage(img,varargin)

      if nargin == 0, return; end

      [payload,varargin] = getClass(varargin,'EBSD');
      if ~isempty(payload), mg.ebsd = payload; end

      if ~isempty(mg.ebsd)

        if ~isa(mg.ebsd,'EBSDgrid'), mg.ebsd = gridify(mg.ebsd); end

        assert(~isa(mg.ebsd,'EBSDhex'),'MTEX:mapImage:hexGrid',...
          ['A mapImage is a regular grid and a hexagonal map is not one. '...
          'Resample it first, e.g. with gridify after interp onto a square '...
          'grid.']);

        % the map states its own layout: the column index advances along d2
        % and the row index along d1. No convention is consulted
        mg.d1 = mg.ebsd.d1; mg.d2 = mg.ebsd.d2;
        mg.origin = mg.ebsd.pos(1,1);

        % a COPY, not the handle - mg.frame.how2plot = ... is the natural way
        % to frame an image, and on a shared handle that would silently
        % restate the caller's own map
        if isempty(mg.ebsd.frame)
          mg.frame = copy(specimenFrame.default);
        else
          mg.frame = copy(mg.ebsd.frame);
        end

      else

        % nothing to take a frame from. Where the row and column indices
        % point relative to a specimen is not derivable from the array, so
        % give it a frame of its own and leave establishing the relation to
        % transformReferenceFrame - the honest state before alignment
        mg.frame = imageFrame;

        dxy = get_option(varargin,'dxy',1);
        mg.d2 = dxy(1) * mg.frame.basis(1);
        mg.d1 = dxy(end) * mg.frame.basis(2);

      end

      mg.img = toDouble(img);

      mg.origin = get_option(varargin,'origin',mg.origin);

      nm = get_option(varargin,'name','');
      if ~isempty(nm)
        assert(isvarname(nm),'MTEX:mapImage:badName',...
          ['The name becomes a field of the EBSD map''s properties, so it '...
          'has to be a valid MATLAB identifier. "%s" is not.'],nm);
        mg.name = nm;
      end

      assert(ndims(mg.img) <= 3,'MTEX:mapImage:tooManyDimensions',...
        'An image is r x c x k, got %s.',mat2str(size(mg.img)));

      assert(abs(dot(normalize(mg.d1),normalize(mg.d2))) < 1e-6,...
        'MTEX:mapImage:notOrthogonal',...
        ['The row and column steps of a regular grid are perpendicular, '...
        'but the ones given are %.1f%s apart.'],...
        angle(mg.d1,mg.d2)./degree,mtexdegchar);

      if ~isempty(mg.ebsd)
        assert(isequal(size(mg.img,[1 2]),size(mg.ebsd)),...
          'MTEX:mapImage:sizeMismatch',...
          ['The image and the map have to be on the same grid, in the same '...
          'array order. The image is %s and the map is %s.'],...
          mat2str(size(mg.img,[1 2])),mat2str(size(mg.ebsd)));
      end

    end

    function pos = get.pos(mg)

      [i,j] = ndgrid(0:size(mg.img,1)-1, 0:size(mg.img,2)-1);
      pos = mg.origin + i.*mg.d1 + j.*mg.d2;

    end

    function iF = get.arrayFrame(mg)
      iF = imageFrame(mg.d2,mg.d1);
    end

    function pC = get.how2plot(mg)
      pC = mg.frame.how2plot;
    end

    function d = get.dx(mg), d = norm(mg.d2); end
    function d = get.dy(mg), d = norm(mg.d1); end
    function k = get.nChannel(mg), k = size(mg.img,3); end

    function varargout = gridSize(mg,dim)
      % the size of the grid this image is on
      %
      % NOT size(mg): a sequence of images is a @mapImage array, so size,
      % numel and length have to keep describing that array. @EBSD can
      % overload them to mean the map because nobody builds an array of EBSD
      % objects; here the array is the point.

      sz = size(mg.img,[1 2]);

      if nargin > 1
        sz = [sz, ones(1,max(0,max(dim(:))-2))];
        varargout{1} = sz(dim);
      elseif nargout <= 1
        varargout{1} = sz;
      else
        sz = [sz, ones(1,max(0,nargout-2))];
        varargout = num2cell(sz(1:nargout));
      end

    end

    function v = double(mg)
      % the raw values, for code that predates this class
      v = mg.img;
    end

    function s = char(mg)

      sz = gridSize(mg);
      s = sprintf('%d x %d',sz(1),sz(2));
      if mg.nChannel > 1, s = sprintf('%s x %d',s,mg.nChannel); end
      s = sprintf('%s  step %.4g x %.4g',s,mg.dx,mg.dy);
      if ~isempty(mg.name), s = sprintf('%s  "%s"',s,mg.name); end
      if ~isempty(mg.ebsd), s = [s '  + map']; end

    end

  end

end

% =========================================================================
function img = toDouble(img)
% values as double in [0,1], the im2double convention without the toolbox

assert(isnumeric(img) || islogical(img),'MTEX:mapImage:notNumeric',...
  'An image is numeric, got %s.',class(img));

if isinteger(img)
  img = double(img) ./ double(intmax(class(img)));
else
  img = double(img);
end

end
