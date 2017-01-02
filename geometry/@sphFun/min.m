function [sF,v] = min(sF1, sF2)
        
if nargin == 1
           
  [sF,pos] = min(sF1.values(:));
           
  v = sF1.vertices(pos);
  v = v.rmOption('resolution');
  
elseif isnumeric(sF1)
            
  sF = sF2;
            
  sF.values = min(sF1, sF.values);
                    
elseif isnumeric(sF2)
            
  sF = sF1;
            
  sF.values = min(sF.values, sF2);
        
else
            
  sF=sF1;
        
  sF.values = min(sF1.values, sF2.values);
   
end
        
end