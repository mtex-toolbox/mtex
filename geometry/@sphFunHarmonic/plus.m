function sF = plus(sF1, sF2)

if isnumeric(sF1)
  sF = sF2;
  sF.fhat(1) = sF.fhat(1)+sF1;
  
elseif isa(sF2,'numeric')
  sF = sF1;
  sF.fhat(1) = sF.fhat(1)+sF2;

else
  [val, index] = max([length(sF1.fhat), length(sF2.fhat)]);
  if index == 1
	  sF = sF1;
	  sF.fhat = sF1.fhat+[sF2.fhat; zeros(length(sF1.fhat)-length(sF2.fhat), 1)];

  else
	  sF = sF2;
	  sF.fhat = sF2.fhat+[sF1.fhat; zeros(length(sF2.fhat)-length(sF1.fhat), 1)];

  end

end

end
