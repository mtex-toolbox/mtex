function value = get(T,pName)
% extract data from a tensor variable
%
%% Syntax
%  d = get(T,'mineral') 
% 
%% Input
%  T     - @tensor
%  pName - property name
%
%% Output
%
%% See also
% tensor/set


switch pName

  case fields(T)
    
    value = T.(pName);
    
  case fields(T.properties)
  
    value = T.properties.(pName);

  otherwise
    
    error('Unknown property!')
    
end
