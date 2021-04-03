classdef SO3FunComposition < SO3Fun
% a class represeneting a function on the rotation group
  
properties
  components
end

methods
  function SO3F = SO3FunComposition(varargin)
    
    isSO3F = cellfun(@(x) isa(x,'SO3Fun'),varargin);
    SO3F.components = varargin(isSO3F);
    
  end
  
  function f = eval(SO3F,rot,varargin)
    
    f = 0;
    for k = 1:lengh(SO3F.components)
      f = f + eval(SO3F.components{k},rot,varargin{:});
    end
    
  end  
  
end


methods (Static = true)
   
    
end


end
