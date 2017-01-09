function [sF,v] = min(sF1, sF2)
        
if nargin == 1
           
  [sF,v] = max(-sF1);
           
  sF = -sF;
  
else
  
  sF = -max(-sF1,-sF2);
   
end
        
end