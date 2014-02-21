classdef (Abstract) misorientationAnalysis
  %MISORIENTATIONANALYSIS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Abstract)
    [mori,weights] = calcMisorientation(ebsd1,varargin)
  end
  
end

