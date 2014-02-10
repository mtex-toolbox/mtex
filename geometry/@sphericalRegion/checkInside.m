 function inside = checkInside(sR,v)
 % check for points to be inside the spherical region
 
 
 inside = true(size(v));
 for i = 1:length(sR.N)
   inside = inside & (dot(v,sR.N(i)) >= sR.alpha(i)-1e-6);
 end
 
 end
