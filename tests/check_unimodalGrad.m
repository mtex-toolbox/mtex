function check_unimodalGrad


%% test 1

cs1 = crystalSymmetry('-3m1');
cs2 = crystalSymmetry('m-3m');

center = orientation.rand(100,cs1,cs2);

odf = unimodalODF(center);

ori = orientation.rand(1000,odf.CS,odf.SS);

g1 = odf.grad(ori(:),'check','delta',0.001*degree);
g2 = odf.grad(ori(:));

if max(norm(g1-g2)./(1+norm(g1))) < 1e-1
  disp(' Unimoal gradient test passed'); 
else
  disp(' Unimoal gradient test failed'); 
end

%% test 2
odf = SantaFe;

ori = orientation.rand(1000,odf.CS,odf.SS);

g1 = odf.grad(ori(:),'check','delta',0.001*degree);
g2 = odf.grad(ori(:));

if max(norm(g1-g2)./norm(g1)) < 1e-2
  disp(' Unimoal gradient test passed'); 
else
  disp(' Unimoal gradient test failed'); 
end

end