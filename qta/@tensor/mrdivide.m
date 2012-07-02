function out = mrdivide(T,S)
% implements T / S
%


if isa(S,'double') 
  
  T.M = T.M / S;
  out = T;
  
end
