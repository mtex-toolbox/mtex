function sF = horzcat(sF1, sF2)

  [bandwidth, I] = max([sF1.bandwidth, sF2.bandwidth]);
  if I == 2
    tmp = sF1;
    sF1 = sF2;
    sF2 = tmp;
  end % sF1 has bigger bandwidth
  sF = S2FunHarmonic( ...
    [sF1.fhat [sF2.fhat; zeros(size(sF1.fhat, 1)-size(sF2.fhat, 1), numel(sF2))]] ...
  );

end
