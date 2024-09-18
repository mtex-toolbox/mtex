function out = isLower(sR,ref)

if nargin==1
  ref = sR.how2plot.outOfScreen;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

out = isUpper(sR,-ref);
 
end
