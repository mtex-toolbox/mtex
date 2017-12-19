function sF = volume(sF1,center,radius)
    
sF = sF1;
   
sF.values = sF1.values;
   
sF = volume(sF.values, center, radius);

end