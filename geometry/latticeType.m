classdef latticeType < int32
% class representing the different Bravais lattices
%
% An enumeration, so a lattice can be compared against its name -
% cs.lattice == 'hexagonal' - and carries the conventions that follow from
% it, above all the default axis angles and whether the three or four digit
% Miller notation applies.
%
% Syntax
%   l = latticeType.hexagonal
%   l = cs.lattice
%
% Class Properties
%  triclinic, monoclinic, orthorhombic, trigonal, tetragonal, hexagonal,
%  cubic, none, icosahedral - the enumeration members
%
% See also
% crystalSymmetry MillerConvention Miller
%
  
  enumeration
    triclinic    (1)
    monoclinic   (2)
    orthorhombic (3)
    trigonal     (4) 
    tetragonal   (5)
    hexagonal    (6)
    cubic        (7)
    none         (8)
    icosahedral  (9)
  end
  
  methods
    
    function abg = defaultAngles(this)
      
      switch this
        case {'trigonal','hexagonal'}
          abg = [90 90 120] * degree;

        otherwise
          abg = [90 90 90] * degree;
      end
      
    end
    
    function out = isTriHex(this)
      
      out = this == latticeType.trigonal || this == latticeType.hexagonal;
      
    end
    
    function out = isEucledean(this)
      
      out = this == latticeType.orthorhombic || ...
        this == latticeType.tetragonal || this == latticeType.cubic;
      
    end

    function out = hklForm(this)
      if isTriHex(this)
        out = 'hkil';
      else
        out = 'hkl';
      end
    end
    
  end
  
end