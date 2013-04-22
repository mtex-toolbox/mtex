function b = bandwidth(odf)
% bandwidth of the ODF

b = zeros(size(odf));
for i = 1:length(odf)
  if check_option(odf(i),'UNIFORM')
    b(i) = -1;
  else
    b(i) = dim2deg(length(odf(i).c_hat));
  end
end

b = min(b(b>=0));
if isempty(b), b = 0;end

