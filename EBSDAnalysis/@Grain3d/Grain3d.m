classdef Grain3d < GrainSet
  % constructor for a 3d-GrainSet
  %
  % *Grain3d* represents 3d grains. a *Grain3d* represents grains and grain
  % boundaries spatially and topologically. It uses formally the class
  % [[GrainSet.GrainSet.html,GrainSet]].
  %
  %% Syntax
  %   grains = Grain3d(grainSet,ebsd)
  %
  %% Input
  % grainSet - @GrainSet
  % ebsd - @EBSD
  %
  %% See also
  % EBSD/calcGrains GrainSet/GrainSet Grain2d/Grain2d
  
  properties
    
  end
  
  methods
    function obj = Grain3d(ebsd)
      obj = obj@GrainSet(ebsd);
      
    end
  end
  
end