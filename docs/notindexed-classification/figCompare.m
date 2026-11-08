function figCompare(ebsd,file)
% the map reconstructed with three alphas and with the selective fill
alpha = [2.8 6.8 16.1];
f = newMtexFigure('layout',[2 2],'figSize','huge');
for k = 1:4
  if k < 4
    [gr,eg] = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alpha',alpha(k));
    ttl = sprintf('alpha = %.1f',alpha(k));
  else
    [gr,eg] = selectiveGrains(ebsd,'wCrack',30);
    ttl = 'alpha = 3.1, pores and cracks filled';
  end
  gr = smoothBoundary(gr);
  if k > 1, nextAxis; end
  plot(eg,'ipfz','micronbar','off'); legend off
  hold on
  plot(gr.boundary,'linewidth',1.2)
  plot(gr(~gr.isIndexed),'FaceColor','k','FaceAlpha',0.35)
  hold off
  mtexTitle(sprintf('%s: %d notIndexed grains',ttl,nnz(~gr.isIndexed)))
end
exportgraphics(f.parent,file,'Resolution',110);
close(f.parent)
end
