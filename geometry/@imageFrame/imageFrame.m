classdef imageFrame < referenceFrame
% the reference frame a raster image is expressed in
%
% An image is an array indexed (row,col). Where that array sits relative to
% the specimen - which specimen directions columns and rows advance along -
% is not derivable from the array itself and has to be established. That is
% the basis, and the transition to another frame is then an ordinary
% rotation, computed by
% <referenceFrame.transformationMatrix.html |transformationMatrix|>.
%
% This is a relation between two frames. Screen directions do not enter it:
% an image frame is what it is whether or not anything is ever plotted. The
% one place a convention does appear is
% <orientation.byScreenAlignment.html |orientation.byScreenAlignment|>,
% which recovers the relation from the assertion that two frames were
% plotted and seen to coincide.
%
% Syntax
%
%   iF = imageFrame                       % col||X, row||Y
%   iF = imageFrame(colDir,rowDir)        % stated directly
%   iF = imageFrame(colDir,rowDir,'name','fsd')
%   iF = imageFrame(ebsd)                 % the layout a gridded map is stored in
%
%   iF = imageFrame.assumedFor(ebsd)      % inferred from the map's convention
%
% Input
%  colDir - @vector3d, the direction along which the column index advances
%  rowDir - @vector3d, the direction along which the row index advances
%  ebsd   - @EBSDgrid, read as col along d2 and row along d1
%
% Class Properties
%  basis     - 1x3 @vector3d, [col, row, col x row]
%  axesNames - {'col','row'}
%  how2plot  - @plottingConvention, seeded to plottingConvention.ij
%
% See also
% referenceFrame specimenFrame orientation/byScreenAlignment

  methods

    function iF = imageFrame(varargin)

      % the column and row directions may be given as two separate vector3d
      % - the superclass takes a ready made 1x3 basis instead, so pull them
      % out and build the basis here before handing the rest over
      % a gridified map states its layout outright - the column index
      % advances along d2 and the row index along d1
      if nargin >= 1 && isa(varargin{1},'EBSDgrid')
        varargin = [{varargin{1}.d2, varargin{1}.d1}, varargin(2:end)];
      end

      isV = find(cellfun(@(x) isa(x,'vector3d'),varargin));
      b = [];

      if numel(isV) >= 2

        col = normalize(varargin{isV(1)});
        row = normalize(varargin{isV(2)});

        assert(isscalar(col) && isscalar(row),...
          'MTEX:imageFrame:notSingle',...
          'The column and row directions have to be one @vector3d each.');

        assert(abs(dot(col,row)) < 1e-6, 'MTEX:imageFrame:notOrthogonal',...
          ['The column and row directions of an image are perpendicular, '...
          'but the ones given are %.1f%s apart.'],...
          angle(col,row)./degree, mtexdegchar);

        % the third axis completes the right handed set, not a free choice
        b = [col, row, cross(col,row)];
        varargin(isV(1:2)) = [];

      end

      iF = iF@referenceFrame(varargin{:});

      % the axis normal to the image is fixed by the other two - it carries
      % no index and so gets no name
      iF.axesNames = {'col','row'};
      if ~isempty(b), iF.basis = b; end

      % a raster is conventionally drawn with row 1 at the top. This is a
      % display detail and not part of what an image frame means - nothing
      % in an indexing path reads it - but byScreenAlignment does, so it
      % must not be left to fall back on the session default
      if isempty(iF.how2plot), iF.how2plot = plottingConvention.ij; end

    end

  end

  methods (Static = true)

    function iF = assumedFor(obj)
      % the image frame implied by a map having been plotted alongside
      %
      % Recovers the relation from the assumption that the user has already
      % aligned the two on screen - see orientation/byScreenAlignment. This
      % is how the relation was stated before it had a home, so it is the
      % backwards compatible default, and it names itself 'assumed from
      % plot' so that an unstated assumption is visible wherever the frame
      % is displayed.
      %
      % Syntax
      %   iF = imageFrame.assumedFor(ebsd)
      %   iF = imageFrame.assumedFor(fr)
      %
      % Input
      %  ebsd - @EBSD, or any object carrying a reference frame
      %  fr   - @referenceFrame, given directly
      %
      % See also
      % orientation/byScreenAlignment

      iF = imageFrame;

      if isa(obj,'referenceFrame')
        fr = obj;
      else
        fr = obj.frame;
        % frame free data follows the session default, which is what the
        % relation was being read off before frames carried it
        if isempty(fr), fr = specimenFrame(obj.how2plot); end
      end

      % the images of X, Y, Z under the inferred rotation are the axes of
      % the image frame expressed in fr - i.e. exactly its basis
      M = matrix(orientation.byScreenAlignment(iF,fr));
      iF.basis = vector3d(M(1,:),M(2,:),M(3,:));

      iF.name = 'assumed from plot';

    end

  end

end
