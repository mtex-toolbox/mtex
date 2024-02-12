function sR = restrict2Lower(sR,ref)
 
if nargin==1
  ref = sR.how2plot.outOfScreen;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

 sR.N = [-ref;sR.N(:)];
 sR.alpha = [0;sR.alpha(:)];
 
 end
