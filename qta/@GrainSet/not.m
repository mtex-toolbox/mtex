function b = not(grains)

b = reshape(full(~any(grains.I_DG,1)),[],1);