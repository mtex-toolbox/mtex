function sF = times(sF1,sF2)

if isnumeric(sF1)
  sF = sF2;
  sF.fhat = sF.fhat*sF1;
  
elseif isnumeric(sF2)
  sF = sF1;
  sF.fhat = sF.fhat*sF2;

else
  error('not yet implemented')

end

end
