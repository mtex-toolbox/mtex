classdef crystalFrame < referenceFrame
% the reference frame glued to the lattice basis of a phase
%
% The basis are the crystal axes a, b, c in canonical Euclidean
% coordinates, with their lengths - the X||a*, Z||c alignment choice
% belongs to this frame, not to the point group. A crystal frame can be
% defined directly by the lattice parameters and alignment options,
% without any symmetry involved.
%
% Syntax
%
%   % by point group and lattice parameters - the usual way to name a phase
%   cF = crystalFrame('cubic')
%   cF = crystalFrame('2/m',[8.6 13 7.2],[90 116 90]*degree,'mineral','orthoclase')
%   cF = crystalFrame('O')
%   cF = crystalFrame('LaueId',9)
%   cF = crystalFrame('SpaceId',153)
%   rot = rotation.map(vector3d(1,1,1),vector3d.Z,vector3d(0,-1,1),vector3d.X);
%   cF = crystalFrame('432','rotAxes',rot)
%
%   % by lattice parameters and alignment alone, the default is X||a*, Z||c
%   cF = crystalFrame([1 2 3],[70 80 120]*degree,'Z||a*')
%   cF = crystalFrame([3 3 5],'X||a')
%
%   % by the axes themselves, and the trivial group carrying another frame
%   cF = crystalFrame(axes)
%   cF = crystalFrame(axes,'name','Forsterite')
%   cF = crystalFrame(otherFrame)
%
% Input
%  name - Schoenflies or International notation of the point group
%  axes - 1x3 @vector3d, the crystal axes a, b, c
%  abc  - length of the crystal axes
%  abg  - angles between the crystal axes alpha, beta, gamma
%
% Options
%  X||a, X||a*, Z||c, ... - alignment of the Cartesian axes
%  EDAX                   - vendor alignment convention of EDAX / TSL / OIM
%  mineral                - name of the phase, which is the frame's identity
%  color                  - colour of the phase in a map
%  pointId                - point group id, for the lattice consistency checks
%  noIntern               - do not unify with the session instance of this frame
%
% Dependent Class Properties
%  abc   - length of the crystal axes
%  abg   - angles between the crystal axes
%  alpha - angle between b and c
%  beta  - angle between c and a
%  gamma - angle between a and b
%
% See also
% referenceFrame specimenFrame crystalSymmetry

  properties (Dependent = true)
    abc         % a, b, c
    abg         % alpha, beta, gamma
    alpha       % angle between b and c
    beta        % angle between c and a
    gamma       % angle between a and b
    axes        % the crystal axes a, b, c - the basis of this frame
    aAxis       % a-axis
    bAxis       % b-axis
    cAxis       % c-axis
    aAxisRec    % a*-axis of the reciprocal coordinate system
    bAxisRec    % b*-axis of the reciprocal coordinate system
    cAxisRec    % c*-axis of the reciprocal coordinate system
    X           % x-axis
    Y           % y-axis
    Z           % z-axis
  end

  methods

    function cF = crystalFrame(varargin)

      % this is for compatibility with using "strings" as input
      try varargin = controllib.internal.util.hString2Char(varargin); catch, end

      % every way of naming a frame resolves to the arguments the frame
      % itself takes, so the superclass constructor is called once and
      % unconditionally - MATLAB does not allow it inside a branch
      [args,post] = readSyntax(varargin);

      cF = cF@referenceFrame(args{:});
      cF.axesNames = get_option(args,'axesNames',{'a','b','c'});

      cF = applySyntax(cF,post);

    end

    function abc = get.abc(cF)
      abc = norm(cF.basis);
    end

    function abg = get.abg(cF)
      abg = angle(cF.basis([2,3,1]),cF.basis([3,1,2]));
    end

    function alpha = get.alpha(cF)
      alpha = angle(cF.basis(2),cF.basis(3));
    end

    function beta = get.beta(cF)
      beta = angle(cF.basis(3),cF.basis(1));
    end

    function gamma = get.gamma(cF)
      gamma = angle(cF.basis(1),cF.basis(2));
    end

    % the crystal axes are the basis under the name crystallography uses
    function v = get.axes(cF), v = cF.basis; end
    function set.axes(cF,v), cF.basis = v; end

    function a = get.aAxis(cF), a = Miller(1,0,0,cF,'uvw'); end
    function b = get.bAxis(cF), b = Miller(0,1,0,cF,'uvw'); end
    function c = get.cAxis(cF), c = Miller(0,0,1,cF,'uvw'); end

    function a = get.aAxisRec(cF), a = Miller(1,0,0,cF); end

    function b = get.bAxisRec(cF)
      d = basisDual(cF);
      b = Miller(d(2),cF);
    end

    function c = get.cAxisRec(cF)
      d = basisDual(cF);
      c = Miller(d(3),cF);
    end

    function x = get.X(cF), x = Miller(vector3d.X,cF,'xyz'); end
    function y = get.Y(cF), y = Miller(vector3d.Y,cF,'xyz'); end
    function z = get.Z(cF), z = Miller(vector3d.Z,cF,'xyz'); end

  end

  methods (Static = true)

    cF = load(fname,varargin)

    cF = byElements(rot,varargin)

  end

end
