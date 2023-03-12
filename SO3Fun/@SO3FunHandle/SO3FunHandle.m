classdef SO3FunHandle < SO3Fun
% a class representing a function on the rotation group by an function
% handle
%
% Syntax
%   SO3F = SO3FunHandle(fun)
%
% Input
%  fun - @function_handle
%
% Output
%  SO3F - @SO3FunHandle
%
% Example
%
%   r = orientation.rand;
%   SO3F = SO3FunHandle(@(rot) angle(rot,r))
%
properties
  fun
  % TODO: antipodal wird weder erkannt noch gesetzt/verwendet
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

%     if isa(rot,'orientation')
%       ensureCompatibleSymmetries(SO3F,rot)
%     end

    s = size(rot);
    rot = rot(:);
    f = SO3F.fun(rot);
    if numel(f)==length(rot)
      f = reshape(f,s);
    end
    if isalmostreal(f)
      f = real(f);
    end
  end

end


methods (Static = true)
   
  SO3F = example(varargin)

end


end
