classdef S1FunHandle < S1Fun
% a class representing a function on 1-sphere by a function handle
%
% Syntax
%   sF = S1FunHandle(fun)
%
% Input
%  fun - @function_handle
%
% Output
%  sF - @S1FunHandle
%
% Example
%
%   sF = S1FunHandle(@(o) sin(o))
%
properties
  fun
  % TODO: antipodal wird weder erkannt noch gesetzt/verwendet
  antipodal = false
  bandwidth = getMTEXpref('maxS1Bandwidth');
end

methods
  
  function sF = S1FunHandle(fun,varargin)
    
    sF.fun = fun;

  end
  
end


methods (Static = true)
   
  sF = example(varargin)

end


end
