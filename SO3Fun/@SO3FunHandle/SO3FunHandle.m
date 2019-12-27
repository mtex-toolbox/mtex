classdef SO3FunHandle < SO3Fun
% a class represeneting a function on the rotation group
  
properties
  fun
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
end

methods
  function SO3F = SO3FunHandle(fun,varargin)
    
    SO3F.fun = fun;
    
    isSym = cellfun(@(x) isa(x,'symmetry'),varargin);
      
    id = find(isSym,2,'first');
    
    if ~isempty(id), SO3F.SRight = varargin{id(1)}; end
    if length(id)>1, SO3F.SLeft = varargin{id(2)}; end
  end
  
  function f = eval(SO3F,rot)
    f = SO3F.fun(rot);
  end  
  
end


methods (Static = true)
   
    
end


end
