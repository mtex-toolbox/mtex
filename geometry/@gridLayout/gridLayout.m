classdef gridLayout < referenceFrame
% the order a grid is stored in - which directions the matrix indices run along
%
% An array is indexed (i,j). Which specimen directions those two indices
% advance along is not derivable from the array itself and has to be
% established. That is the layout, and the transition between two layouts is
% a signed permutation, applied by
% <gridLayout.layoutIndex.html |layoutIndex|>.
%
% This is a relation between the array and a frame, and no screen enters it:
% a layout is what it is whether or not anything is ever plotted. Dimension 1
% is the row index, dimension 2 the column index, in that order - the order
% |size(A)| and |A(i,j)| are written in. A direction may point either way, so
% a layout also says whether an index runs with the coordinate or against it.
%
% Syntax
%
%   gL = gridLayout                       % row||Y, col||X
%   gL = gridLayout(rowDir,colDir)        % stated directly
%   gL = gridLayout(rowDir,colDir,'name','fsd')
%   gL = gridLayout(ebsd)                 % the layout a gridded map is in
%
%   gL = gridLayout.columnMajor           % the two named layouts
%   gL = gridLayout.rowMajor
%   gL = gridLayout.fromOption(varargin)  % whichever a call asks for
%
%   gL = gridLayout.assumedFor(fr)        % the order a frame is drawn in
%
% Input
%  rowDir - @vector3d, the direction the row index advances along
%  colDir - @vector3d, the direction the column index advances along
%  ebsd   - @EBSDgrid, read as row along d1 and col along d2
%
% Class Properties
%  basis     - 1x3 @vector3d, [row, col, row × col]
%  axesNames - {'row','col'}
%
% See also
% referenceFrame specimenFrame gridLayout/layoutIndex EBSD/gridify

  methods

    function gL = gridLayout(varargin)

      % the row and column directions may be given as two separate vector3d
      % - the superclass takes a ready made 1x3 basis instead, so pull them
      % out and build the basis here before handing the rest over
      % a gridified map states its layout outright - the row index advances
      % along d1 and the column index along d2
      if nargin >= 1 && isa(varargin{1},'EBSDgrid')
        varargin = [{varargin{1}.d1, varargin{1}.d2}, varargin(2:end)];
      end

      isV = find(cellfun(@(x) isa(x,'vector3d'),varargin));
      b = [];

      if numel(isV) >= 2

        row = normalize(varargin{isV(1)});
        col = normalize(varargin{isV(2)});

        assert(isscalar(row) && isscalar(col),...
          'MTEX:gridLayout:notSingle',...
          'The row and column directions have to be one @vector3d each.');

        assert(abs(dot(row,col)) < 1e-6, 'MTEX:gridLayout:notOrthogonal',...
          ['The row and the column direction of a grid are perpendicular, '...
          'but the ones given are %.1f%s apart.'],...
          angle(row,col)./degree, mtexdegchar);

        % the third axis completes the right handed set, not a free choice
        b = [row, col, cross(row,col)];
        varargin(isV(1:2)) = [];

      end

      % a basis may also arrive ready made, which the superclass takes
      given = ~isempty(b) || any(cellfun(@(x) isa(x,'vector3d'),varargin));

      gL = gL@referenceFrame(varargin{:});

      % the axis normal to the grid carries no index and so gets no name
      gL.axesNames = {'row','col'};

      if ~isempty(b)
        gL.basis = b;
      elseif ~given
        % what gridify stores a map in: rows along y, columns along x
        gL.basis = [yvector, xvector, -zvector];
      end

    end

  end

  methods (Static = true)

    function gL = columnMajor
      % one scan row per matrix row - dimension 1 along y, dimension 2 along x
      gL = gridLayout(yvector,xvector,'name','columnMajor');
    end

    function gL = rowMajor
      % the transposed layout - dimension 1 along x, dimension 2 along y
      gL = gridLayout(xvector,yvector,'name','rowMajor');
    end

    function gL = fromOption(list)
      % the layout a gridify call asks for
      %
      % A layout given outright wins over the two flags. This is the one
      % place the names columnMajor and rowMajor are attached to a layout.
      % The option list is passed as one cell, as
      % <plottingConvention.fromOption.html plottingConvention.fromOption>
      % takes it.
      %
      % Syntax
      %   gL = gridLayout.fromOption           % columnMajor, the default
      %   gL = gridLayout.fromOption(varargin)
      %
      % Input
      %  list - the option list
      %
      % See also
      % EBSD/gridify EBSDsquare/transformReferenceFrame

      if nargin == 0, list = {}; end

      gL = getClass(list,'gridLayout',[]);

      if isempty(gL)
        if check_option(list,'rowMajor')
          gL = gridLayout.rowMajor;
        else
          gL = gridLayout.columnMajor;
        end
      end

    end

    function gL = assumedFor(obj)
      % the layout implied by a frame having been plotted alongside
      %
      % An array is drawn row 1 at the top and the column index to the
      % right, which is what plottingConvention.ij says. Read against a
      % frame's own convention that fixes the layout, and is how the
      % relation was stated before it had a home - so it is the backwards
      % compatible default, and it names itself 'assumed from plot' so that
      % an unstated assumption is visible wherever the layout is displayed.
      %
      % Syntax
      %   gL = gridLayout.assumedFor(ebsd)
      %   gL = gridLayout.assumedFor(fr)
      %
      % Input
      %  ebsd - @EBSD, or any object carrying a reference frame
      %  fr   - @referenceFrame, given directly
      %
      % See also
      % orientation/byScreenAlignment

      if isa(obj,'referenceFrame')
        fr = obj;
      else
        fr = obj.frame;
        % frame free data follows the session default, which is what the
        % relation was being read off before frames carried it
        if isempty(fr), fr = specimenFrame(obj.how2plot); end
      end

      assert(~isempty(fr.how2plot),'MTEX:gridLayout:noConvention',...
        ['The frame needs a plotting convention of its own. An empty one '...
        'follows the session default, so the layout inferred from it would '...
        'change when the session default changes.']);

      % an array is drawn in the ij convention, so the two conventions being
      % the same picture is what relates the array axes to the frame's
      rot = fr.how2plot.rot * inv(plottingConvention.ij.rot); %#ok<MINV>

      gL = gridLayout;
      gL.basis = rotate(gL.basis,rot);
      gL.name = 'assumed from plot';

    end

  end

end
