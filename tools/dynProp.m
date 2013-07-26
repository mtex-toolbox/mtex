classdef dynProp
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    prop = struct
  end
  
  methods
    
    function dp = dynProp(varargin)          
      
      dp.prop = struct(varargin{:});      
      
    end
    
    function value = subsref(dp,s)
      
      value = subsref(dp.prop,s);
      
    end
    
    function dp = subsasgn(dp,s,value)
      
      dp.prop = subsasgn(dp.prop,s,value);
      
    end
       
    function dp = setProp(dp,name,value)
      dp.prop.(name) = value;
    end
    
    function value = getProp(dp,name)
      value = dp.prop.(name);
    end
    
    function out = isProp(dp,name)
      out = isfield(dp.prop,name);
    end
    
  end
  
end
