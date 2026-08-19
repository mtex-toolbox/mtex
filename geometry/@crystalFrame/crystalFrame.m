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
%   cF = crystalFrame(axes)
%   cF = crystalFrame(axes,'name','Forsterite')
%
%   % by lattice parameters and alignment, the default is X||a*, Z||c
%   cF = crystalFrame([1 2 3],[70 80 120]*degree,'Z||a*')
%   cF = crystalFrame([3 3 5],'X||a')
%
% Input
%  axes - 1x3 @vector3d, the crystal axes a, b, c
%  abc  - length of the crystal axes
%  abg  - angles between the crystal axes alpha, beta, gamma
%
% Options
%  X||a, X||a*, Z||c, ... - alignment of the Cartesian axes
%  EDAX                   - vendor alignment convention of EDAX / TSL / OIM
%  pointId                - point group id, for the lattice consistency checks
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
  end

  methods

    function cF = crystalFrame(varargin)

      % lattice parameters given - compute the axes like crystalSymmetry
      % always has; without a point group the geometry is treated as
      % triclinic, which gives the identical frame for every lattice and
      % merely skips the lattice specific consistency checks
      if ~isempty(varargin) && isnumeric(varargin{1})

        abc = varargin{1};
        varargin(1) = [];

        id = get_option(varargin,'pointId',1);

        if ~isempty(varargin) && isnumeric(varargin{1})
          angles = varargin{1};
          if any(angles > 2*pi), angles = angles * degree; end
          varargin(1) = [];
        else
          angles = symmetry.pointGroups(id).lattice.defaultAngles;
        end

        varargin = [{calcAxis(id,abc,angles,varargin{:})}, varargin];

      end

      cF = cF@referenceFrame(varargin{:});
      cF.axesNames = get_option(varargin,'axesNames',{'a','b','c'});

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

  end

end
