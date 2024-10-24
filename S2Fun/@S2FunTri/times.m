function sF = times(sF1,sF2)
% overloads |sF1 .* sF2|
%
% Syntax
%   sF = sF1 .* sF2
%   sF = a .* sF2
%   sF = sF1 .* a
%
% Input
%  sF1, sF2 - @S2Fun
%  a - double
%
% Output
%  sF - @S2Fun
%
       
if isnumeric(sF1)
  sF = sF2;
  
  sF.values = sF2.values;
  
  sF.values = times(sF1, sF.values);
  
elseif isnumeric(sF2)
            
  sF = sF1;
  
  sF.values = sF1.values;
  
  sF.values = times(sF1.values, sF2);
            
else
            
  sF=sF1;
            
  sF.values = times(sF1.values, sF2.values);
        
end
        
end
