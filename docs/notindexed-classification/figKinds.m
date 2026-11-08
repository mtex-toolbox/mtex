function figKinds(ebsd,file)
% the map reconstructed with per-kind radii: default, pores, cracks, all three
opt = {{}, {'alphaPore',inf}, {'alphaCrack',15}, {'alphaPore',inf,'alphaCrack',15,'alphaPocket',6}};
ttl = {'alpha = 3.1', 'alphaPore = inf', 'alphaCrack = 15', 'alphaPore = inf, alphaPocket = 6, alphaCrack = 15'};
f = newMtexFigure('layout',[2 2],'figSize','huge');
for k = 1:4
  [gr,eg] = calcGrains(ebsd,'angle',10*degree,'minPixel',5,opt{k}{:});
  gr = smoothBoundary(gr);
  if k > 1, nextAxis; end
  plot(eg,'ipfz','micronbar','off'); legend off
  hold on
  plot(gr.boundary,'linewidth',1.2)
  plot(gr(~gr.isIndexed),'FaceColor','k','FaceAlpha',0.35)
  hold off
  mtexTitle(sprintf('%s: %d notIndexed grains',ttl{k},nnz(~gr.isIndexed)))
end
exportgraphics(f.parent,file,'Resolution',110);
close(f.parent)
end
