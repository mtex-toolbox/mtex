function sF = plus(sF1,sF2)
     
if isnumeric(sF1)
            
  sF = sF2;
  sF.fhat(1) = sF.fhat(1) + sF1;
  
elseif isa(sF2,'numeric')
  
  sF = sF1;
  sF.fhat(1) = sF.fhat(1) + sF2;
     
else
            
  sF = sF1;       
  sF.hat = sF1.hat + sF2.hat;
  
end
        
end