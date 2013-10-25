classdef Grain2d < GrainSet
% constructor for a 2d-GrainSet
%
% *Grain2d* represents 2d grains. a *Grain2d* represents grains and grain
% boundaries spatially and topologically. It uses formally the class
% [[GrainSet.GrainSet.html,GrainSet]].
%
% Syntax
%   grains = Grain2d(boundaryEdgeOrder,ebsd)
%
% Input
%  grainSet - @GrainSet
%  ebsd - @EBSD
%
% See also
% EBSD/calcGrains GrainSet/GrainSet Grain3d/Grain3d


  properties
    boundaryEdgeOrder
  end
  
  methods
    function obj = Grain2d(grainStruct,varargin)
      
      obj = obj@GrainSet(grainStruct,varargin{:});      
      obj.boundaryEdgeOrder = grainStruct.boundaryEdgeOrder;
      
    end
  end


end
