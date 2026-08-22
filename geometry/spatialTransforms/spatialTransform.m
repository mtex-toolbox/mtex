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
% Syntax
%
%   posB = eval(T,posA)
%   posB = T * posA               % the same
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
    s = char(T)

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

    function display(T,varargin) %#ok<DISPLAY> every MTEX class overloads it

      displayClass(T,inputname(1),varargin{:});
      if length(T) > 1, disp([' size: ' size2str(T)]); end
      disp(' ');

      for k = 1:length(T), disp(['  ' char(T(k))]); end
      disp(' ');

    end

  end

  methods

    function tf = isid(T) %#ok<MANU>
      % true if the transform leaves every position where it is
      tf = false;
    end

    function T = absorb(T1,T2)
      % the product as a single transform, or empty if it needs a composite

      if isid(T1)
        T = T2;
      elseif isid(T2)
        T = T1;
      else
        T = spatialTransform.empty;
      end

    end

  end

  methods (Static, Sealed, Access = protected)

    function T = getDefaultScalarElement
      T = spatialTransformId;
    end

  end

end
