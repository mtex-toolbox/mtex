function out = isUpper(sR, ref)

sR.antipodal = false;
 
if nargin==1
  ref = sR.how2plot.outOfScreen;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

if sR.checkInside(ref)
 
  out = true;

elseif any(sR.N == -ref) && any(sR.alpha(sR.N == -ref)>=0)
   
  out = false;
   
else
   
  r = regularS2Grid;
  r(dot(r,ref)<+1e-6) = [];
  out = volume(sR.restrict2Upper(ref),r)>0;
   
 end
  
 end
