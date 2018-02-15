function [sF,v] = max(sF1,sF2)
        
if nargin == 1
  
  [sF,pos] = max(sF1.values(:));
  
  v = sF1.vertices(pos);
  v = v.rmOption('resolution');
  
elseif isnumeric(sF1)
  
  sF = sF2;
  
  sF.values = max(sF.values, sF1);
  
elseif isnumeric(sF2)
  
  sF = sF1;
  
  sF.values = max(sF1.values, sF2);
        
else
        
  sF = sF1;
        
  sF.values=max(sF1.values, sF2.values);
        
end
      
end