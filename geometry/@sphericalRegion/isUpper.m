 function out = isUpper(sR)
 
 sR.antipodal = false;
 %out = sR.checkInside(zvector);
 
 r = regularS2Grid;
 r(r.z<+1e-6) = [];
 out = volume(sR.restrict2Upper,r)>0;
 
 end
