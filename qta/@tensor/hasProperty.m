function value = hasProperty(T,pName)
% check whether tensor T has a specific property
%
%% Syntax
%  d = hasProperty(T,'Property Name') 
% 
%% Input
%  T     - @tensor
%  pName - property name
%
%% Output
%
%% See also
% EBSD/set EBSD/get

value = isfield(T,pName) | isfield(T.properties,pName);
