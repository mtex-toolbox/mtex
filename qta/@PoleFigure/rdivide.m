function npf = rdivide(arg1,arg2)
% implements pf1 ./ b and a ./ pf2
%
% overload the .* operator, i.e. one can now write x .* pf in order to
% scale the @PoleFigure pf by the factor x 
%
% See also
% PoleFigure_index PoleFigure/plus PoleFigure/minus

if isa(arg1,'double'), npf = arg2; else npf = arg1;end

for i = 1:length(npf)
    
  if isa(arg1,'double'), l = arg1(i); else l = arg1(i).intensities; end;
  
  if isa(arg2,'double'), r = arg2(i); else r = arg2(i).intensities; end

  if length(r) > 1, r = reshape(r,size(l));end
  
  npf(i).intensities = l./r;
    
end
