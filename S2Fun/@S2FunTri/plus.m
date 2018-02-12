function sF = plus(sF1,sF2)
     
if isnumeric(sF1)
            
  sF = sF2;
  sF.values = sF.values + sF1;
  
elseif isa(sF2,'numeric')
  
  sF = sF1;
  sF.values = sF1.values + sF2;
  
else
            
  sF = sF1;
            
  sF.values = sF1.values + sF2.values;
  
  %sF.values = (sF1.values - sF2.values) + sF1.values;
end
        
end