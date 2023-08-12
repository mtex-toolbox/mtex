function sR = restrict2Upper(sR,ref)
 
if nargin==1
  ref = zvector;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

sR.N = [ref;sR.N(:)];
sR.alpha = [0;sR.alpha(:)];
 
end
