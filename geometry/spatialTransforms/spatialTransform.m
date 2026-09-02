classdef spatialTransform < matlab.mixin.Heterogeneous
% a map from position to position, as an object
%
% A spatial transform relates two coordinate frames of one physical object -
% the distortion between an EBSD map and an image of the same area, the
% drift accumulated during a scan, the projection of a tilted specimen.
% Unlike a bare function handle it composes, inverts, displays, and can be
% saved and applied to a second data set.
%
% Direction is fixed once and everything follows from it:
%
%   T maps a position in frame A to the same physical point's position in
%   frame B. T2 * T1 composes in matrix order - T1 is applied first.
%   Filling an output grid always uses inv(T), never T: for each target
%   pixel, ask where it came from.
%
% Transforms are 2D - they act on x and y and leave z alone.
%
% Subclasses of one base may be collected in one array, so a chain of
% differently modelled hops is [T1 T2 T3] rather than a cell array.
%
% AN ARRAY IS A CHAIN, not a collection of N transforms: [T1 T2 T3] means
% apply T1, then T2, then T3, and it is the composite T1 + T2 + T3 written
% out. So its inverse is [inv(T3) inv(T2) inv(T1)] - inverting REVERSES, as
% spatialTransformComposite/inv already does with its stages. This is the one
% place the class departs from the MTEX reading where an array is N entities
% and every method is elementwise. See docs/adr/0007.
%
% None of that is implemented yet. Every method here takes one transform, and
% an array is only a container: MATLAB dispatches a method on a heterogeneous
% array only if it is sealed, and only mtimes, plus and display are, so
% inv(T), isid(T) and char(T) all fail on a sequence. Until they are sealed,
% fold the chain with * - inv(T(3)*T(2)*T(1)) - or go hop by hop with
% arrayfun(@inv,T,'UniformOutput',false), which does not reverse.
%
% There are two ways to put two transforms together, and they are not the
% same operation:
%
%   T1 + T2   builds a MODEL. It reads left to right, T1 applied first, and
%             it keeps both as stages. Only a literal spatialTransformId is
%             dropped, since that is the class that MEANS nothing separates
%             the two frames.
%   T2 * T1   COMPOSES. It reads in matrix order, T1 applied first, and it
%             simplifies where it can - two affines make a third, and an
%             operand that reports isid disappears.
%
% Use + to declare a distortion that is about to be fitted, * for
% transforms that already are. An unfitted prototype has zero coefficients
% and so reports isid, which is why the two differ where it matters:
% shift * drift is a bare drift with the shift silently gone, while
% shift + drift is the two stage model it looks like.
%
% Note that + is not the pointwise + of vector3d or S2Fun. It chains the
% maps, it does not add the displacements - though for displacements small
% against the scale they vary on the two agree to first order, which is why
% the notation reads the way it does.
%
% Syntax
%
%   posB = eval(T,posA)
%   posB = T * posA               % the same
%   T    = T1 + T2                % chain as stages, T1 applied first
%   T    = T2 * T1                % compose, T1 applied first
%   Tinv = inv(T)
%   tf   = isid(T)
%
% Input
%  T    - @spatialTransform
%  posA - @vector3d
%
% Output
%  posB - @vector3d
%  Tinv - @spatialTransform
%
% Derived Classes
%  spatialTransformId        - the identity
%  spatialTransformShift     - 2D affine, as a homogeneous matrix
%  spatialTransformHandle    - wraps a function handle
%  spatialTransformComposite - an ordered list of stages
%
% See also
% EBSD/transform grain2d/transform

  methods (Abstract = true)

    pos = eval(T,pos)
    T = inv(T)
    s = paramChar(T)

  end

  methods (Sealed = true)

    function out = mtimes(T1,T2)
      % compose two transforms, or apply one to positions

      if isa(T2,'vector3d'), out = eval(T1,T2); return; end

      assert(isa(T1,'spatialTransform') && isa(T2,'spatialTransform'),...
        'MTEX:spatialTransform:badProduct',...
        ['A spatial transform multiplies another transform, or a @vector3d '...
        'on the right. Got %s * %s.'],class(T1),class(T2));

      out = absorb(T1,T2);
      % the composite takes its stages in application order, so T2 first
      if isempty(out), out = spatialTransformComposite(T2,T1); end

    end

    function T = plus(T1,T2)
      % chain two transforms as stages, T1 applied first
      %
      % + builds a model where * composes one. * absorbs an operand that
      % reports isid, and an unfitted prototype has zero coefficients and
      % so reports exactly that - shift * drift is a bare drift with the
      % shift silently gone. + drops only a literal spatialTransformId,
      % the class that MEANS nothing separates the two frames, so a
      % prototype chain survives being written down.
      %
      % Not the pointwise + of vector3d or S2Fun: this chains the maps
      % rather than adding the displacements.

      assert(isa(T1,'spatialTransform') && isa(T2,'spatialTransform'),...
        'MTEX:spatialTransform:badSum',...
        ['A spatial transform chains with another spatial transform. '...
        'Got %s + %s.'],class(T1),class(T2));

      assert(isscalar(T1) && isscalar(T2),...
        'MTEX:spatialTransform:badSum',...
        ['+ chains the stages within one transform. A sequence of hops '...
        'is an array, [T1 T2 T3], not a sum. Got %s + %s.'],...
        size2str(T1),size2str(T2));

      % by class, never by isid - that is the whole difference from *
      if isa(T1,'spatialTransformId'), T = T2; return; end
      if isa(T2,'spatialTransformId'), T = T1; return; end

      T = spatialTransformComposite(T1,T2);

    end

    function display(T,varargin) %#ok<DISPLAY> every MTEX class overloads it
      % one row per transform, with the stages of a multi stage one below it
      %
      % An array of transforms is a sequence of hops and most hops have
      % stages, so what is worth reading off is which model each hop is and
      % what each of its stages came out as. char says the same thing on one
      % line, joined by arrows, which past two stages cannot be read.

      displayClass(T,inputname(1),varargin{:});
      if length(T) > 1, disp([' size: ' size2str(T)]); end
      disp(' ');

      if isempty(T), return; end

      % only a sequence numbers its entries
      num = length(T) > 1;
      matrix = cell(0,3+num);

      for k = 1:length(T)

        stages = stageList(T(k));

        if length(stages) <= 1
          % nothing inside it, so the stage column has nothing to say
          block = {shortChar(T(k)),'·',paramChar(T(k))};
        else
          block = [repmat({''},length(stages),1), ...
            arrayfun(@shortChar,stages(:),'UniformOutput',false), ...
            arrayfun(@paramChar,stages(:),'UniformOutput',false)];
          % the model names the hop, so it sits on its first row alone
          block{1,1} = shortChar(T(k));
        end

        if num
          block = [repmat({''},size(block,1),1), block]; %#ok<AGROW>
          block{1,1} = int2str(k);
        end

        matrix = [matrix; block]; %#ok<AGROW>

      end

      label = {'model','stage','parameters'};
      if num, label = [{''} label]; end

      cprintf(wrapLastColumn(matrix,label),'-L',' ','-Lc',label,...
        '-d','  ','-ic',true,'-la',true);

      disp(' ');

    end

  end

  methods

    function s = shortChar(T)
      % what KIND of transform this is, for a table column
      %
      % char(T) states what a transform IS, name and coefficients in one
      % line. A table wants the two apart, so display pairs this with
      % paramChar, which gives the coefficients alone.

      s = lower(erase(class(T),'spatialTransform'));

    end

    function s = char(T)
      s = [shortChar(T) '  ' paramChar(T)];
    end

    function opt = fitOptions(~)
      % what the static fit of this class has to be told to fit one like it
      opt = {};
    end

    function H = matrix(~)
      % the homogeneous matrix, for a transform that is one
      H = [];
    end

    function stages = stageList(T)
      % what a multi stage transform is built from, itself if it has none
      %
      % A tilt is fitted as a projective, then a polynomial on what that
      % leaves, then another - each against a freshly measured residual,
      % which is why the class only says what its stages are and the caller
      % drives the loop over them.
      %
      % NOT isid: an unfitted prototype has zero coefficients and so reports
      % itself as the identity. Only spatialTransformId means nothing
      % separates the pair, the same class-not-value rule that plus applies.

      stages = T;

    end

    function tf = isid(T) %#ok<MANU>
      % true if the transform leaves every position where it is
      tf = false;
    end

    function u = displacement(T,pos)
      % where each position goes, minus where it started
      u = eval(T,pos) - pos;
    end

    function n = norm(T,pos)
      % how far the transform moves each of the given positions
      n = norm(displacement(T,pos));
    end

    function F = discretize(T,pos)
      % the same transform sampled at pos, as a @spatialTransformField
      %
      % Collapses a chain of any length to one interpolated field, which is
      % what to do when a composite is about to be evaluated many times.

      F = spatialTransformField(pos(:),displacement(T,pos(:)));

    end

    function T = absorb(T1,T2)
      % the product as a single transform, or empty if it needs a composite
      %
      % Two transforms given by homogeneous matrices multiply into a third,
      % which is an affine when its last row says so and a projective
      % otherwise.

      if isid(T1), T = T2; return; end
      if isid(T2), T = T1; return; end

      T = spatialTransform.empty;

      H1 = matrix(T1); H2 = matrix(T2);
      if isempty(H1) || isempty(H2), return; end

      H = H1 * H2;
      if norm(H(3,:) - [0 0 1]) < 1e-12
        T = spatialTransformShift(H);
      else
        T = spatialTransformProjective(H);
      end

    end

  end

  methods (Static, Sealed, Access = protected)

    function T = getDefaultScalarElement
      T = spatialTransformId;
    end

  end

end

% =========================================================================
function matrix = wrapLastColumn(matrix,label)
% break the parameters over further rows so the table fits the window
%
% The parameters are the wide column and the only one that may be broken, so
% what the others take up is measured and the rest goes to it. One column is
% left free - filling the last one makes the command window wrap the row
% itself, in the middle of the indent.

n = size(matrix,2);

w = get(0,'CommandWindowSize');
% headless the command window has no size to report
if w(1) < 40, w = 80; else, w = w(1); end

colw = cellfun(@numel,[label(1:n-1); matrix(:,1:n-1)]);
budget = max(30,w - 1 - sum(max(colw,[],1) + 2) - 1);

out = cell(0,n);

for k = 1:size(matrix,1)

  lines = split(string(wraptext(matrix{k,n},budget)),newline);

  for l = 1:numel(lines)
    row = matrix(k,:);
    if l > 1, row(1:n-1) = {''}; end
    row{n} = char(lines(l));
    out(end+1,:) = row; %#ok<AGROW>
  end

end

matrix = out;

end
