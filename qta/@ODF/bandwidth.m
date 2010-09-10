function b = bandwidth(odf)
% bandwidth of the ODF

for i = 1:length(odf)
  if check_option(odf(i),'UNIFORM')
    b(i) = -1;
  else
    b(i) = dim2deg(length(odf(i).c_hat));
  end
end

b = min([0,b(b>=0)]);

