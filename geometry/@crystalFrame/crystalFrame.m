classdef crystalFrame < referenceFrame
% the reference frame glued to the lattice basis of a phase
%
% The basis are the crystal axes a, b, c in canonical Euclidean
% coordinates, with their lengths - the X||a*, Z||c alignment choice
% belongs to this frame, not to the point group.
%
% Syntax
%
%   cF = crystalFrame(axes)
%   cF = crystalFrame(axes,'name','Forsterite')
%
% Input
%  axes - 1x3 @vector3d, the crystal axes a, b, c
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
      cF = cF@referenceFrame(varargin{:});
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
