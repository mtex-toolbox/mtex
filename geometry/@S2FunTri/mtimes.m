function sF = mtimes(sF1,sF2)
       
if isnumeric(sF1)
  
  sF = sF2;
  
  sF.values = sF2.values;
  
  sF.values = mtimes(sF1, sF.values);
  
elseif isnumeric(sF2)
  
  sF = sF1;
  
  sF.values = sF1.values;
  
  sF.values = mtimes(sF1.values, sF2);
else
  
  sF = sF1;
  
  sF.values = mtimes(sF1.values, sF2.values);
  
end

end
