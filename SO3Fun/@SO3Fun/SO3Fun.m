classdef SO3Fun
% a class representing a function on the rotational group

  properties
    S1 = crystalSymmetry
    S2 = specimenSymmetry
  end    

  
  properties (Dependent = true)
    CS
    SS 
  end
  
  methods
    
    function SO3F = SO3Fun(varargin)
      
      isCS = cellfun(@(x) isa(x,'symmetry'),varargin);
      
      id = find(isCS,2,'first');
      
      if ~isempty(id), SO3F.S1 = varargin{id(1)}; end
      if length(id)>1, SO3F.S2 = varargin{id(2)}; end
      
    end
    
    
    function CS = get.CS(SO3F)
      CS = SO3F.S1;      
    end
    
    function SS = get.SS(SO3F)
      SS = SO3F.S2;      
    end
    
    function SO3F = set.CS(SO3F,CS)
      SO3F.S1 = CS;
    end
    
    function SO3F = set.SS(SO3F,SS)
      SO3F.S2 = SS;
    end
    
  end
  
  
  methods (Abstract = true)
    
    f = eval(F,v,varargin)
    
  end
  
end