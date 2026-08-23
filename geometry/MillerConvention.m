classdef MillerConvention < int32
% class representing the different Miller conventions
%
% An enumeration of the ways a crystal direction may be written: the three
% and four digit reciprocal forms hkl and hkil, the direct forms uvw and
% UVTW, and plain Cartesian xyz. It also carries which brackets belong to
% each, and the sign tells reciprocal from direct.
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
    
    function [left,right] = brackets(this)
      
      if this > 0

        left= '['; right = ']';

      elseif this < 0

        left= '('; right= ')';

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