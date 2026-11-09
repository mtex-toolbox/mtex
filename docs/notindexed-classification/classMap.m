function rgb = classMap(P,info,c,thinLong)
% the map coloured by the class of every notIndexed part, thin elongated parts darker
col = [0.65 0.65 0.65; 0.85 0.1 0.1; 0 0 0; 0.1 0.35 0.9; 0.95 0.6 0; 0.35 0.35 0.35];
cl = zeros(info.sz);
cl(P > 0) = double(c(P(P > 0)));
cl(ismember(P,find(thinLong))) = 6;
rgb = repmat(reshape([0.94 0.94 0.94],1,1,3),info.sz);
rgb(repmat(~info.foot,1,1,3)) = 1;
for k = 1:size(col,1)
  for ch = 1:3
    x = rgb(:,:,ch); x(cl == k) = col(k,ch); rgb(:,:,ch) = x;
  end
end
end
