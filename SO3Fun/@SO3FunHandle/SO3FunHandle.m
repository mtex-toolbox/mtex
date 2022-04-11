classdef SO3FunHandle < SO3Fun
% a class representing a function on the rotation group
  
properties
  fun
  antipodal = false
  SLeft  = specimenSymmetry
  SRight = specimenSymmetry
  bandwidth = 96
end

methods
  function SO3F = SO3FunHandle(fun,varargin)
    
    SO3F.fun = fun;

    [SRight,SLeft] = extractSym(varargin);
    SO3F.SRight = SRight;
    SO3F.SLeft = SLeft;
    
  end
  
  function f = eval(SO3F,rot,varargin)
    s = size(rot);
    rot = rot(:);
    f = SO3F.fun(rot);
    if numel(SO3F)==1
      f = reshape(f,s);
    end
  end

end


methods (Static = true)
   
  SO3F = example(varargin)

end


end
