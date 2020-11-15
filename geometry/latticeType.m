classdef latticeType < int32
% class representing the different Bravais lattices
  
  enumeration
    triclinic    (1)
    monoclinic   (2)
    orthorhombic (3)
    trigonal     (4) 
    tetragonal   (5)
    hexagonal    (6)
    cubic        (7)
    none         (8)
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
    
  end
  
end