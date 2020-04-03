 function out = isLower(sR)

 sR.antipodal = false;
 
 if sR.checkInside(-zvector)
 
   out = true;

 elseif any(sR.N == zvector) && any(sR.alpha(sR.N == zvector)>=0)
   
   out = false;
   
 else
   
   r = regularS2Grid;
   r(r.z>-1e-6) = [];
   out = volume(sR.restrict2Lower,r)>0;
   
 end
 
 end
