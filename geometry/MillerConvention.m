classdef MillerConvention < int32
% class representing the different Miller conventions
%
% An enumeration of the ways a crystal direction may be written: the three
% and four digit reciprocal forms hkl and hkil, the direct forms uvw and
% UVTW, and plain Cartesian xyz. It also carries which brackets belong to
% each, and the sign tells reciprocal from direct.
%
% Each form has two bracket pairs, the single one and the family one the
% literature uses for the symmetrically equivalent set - (hkl) against
% {hkl}, [uvw] against <uvw>. Which of the two is written is not part of the
% convention: it follows from whether a point group is there to make a
% family, see <MillerConvention.brackets.html brackets>.
%
% Syntax
%   c = MillerConvention.hkil
%   m.dispStyle = 'uvw'
%
% Class Properties
%  hkil, hkl, xyz, uvw, UVTW - the enumeration members
%
% See also
% Miller latticeType crystalSymmetry
%
  
  enumeration
    hkil         (-2)
    hkl          (-1)
    xyz          (0)
    uvw          (1) 
    UVTW         (2)
  end
  
  methods
    
    function out = isReciprocal(this)
      
      out = this < 0;
      
    end
    
    function [left,right] = brackets(this,isFamily)
      % the brackets this form is written in
      %
      % Syntax
      %   [l,r] = brackets(c)        % (hkl) and [uvw], one plane or direction
      %   [l,r] = brackets(c,true)   % {hkl} and <uvw>, the equivalent set

      if nargin < 2, isFamily = false; end

      if this > 0

        if isFamily, left = '<'; right = '>'; else, left = '['; right = ']'; end

      elseif this < 0

        if isFamily, left = '{'; right = '}'; else, left = '('; right = ')'; end

      else

        left = ''; right= '';

      end
    end
    
    function this = make4Digit(this,cs)
      % ensure 4 digit dispStyle when possible
      
      if cs.lattice.isTriHex
        this = MillerConvention(2 * sign(this));
      else
        this = MillerConvention(sign(this));
      end
      
    end
    
  end  
end