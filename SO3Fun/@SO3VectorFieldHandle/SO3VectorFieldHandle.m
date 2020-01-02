classdef SO3VectorFieldHandle < SO3VectorField
% a class represeneting a vector field on SO(3)
  
properties
  fun
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
end
  
methods
  function SO3VF = SO3VectorFieldHandle(fun,varargin)
    
    SO3VF.fun = fun;
    
    isSym = cellfun(@(x) isa(x,'symmetry'),varargin);
      
    id = find(isSym,2,'first');
    
    if ~isempty(id), SO3VF.SRight = varargin{id(1)}; end
    if length(id)>1, SO3VF.SLeft = varargin{id(2)}; end
    
  end
  
  function f = eval(SO3VF,ori,varargin)
    f = SO3VF.fun(ori);
  end
  
end

end
