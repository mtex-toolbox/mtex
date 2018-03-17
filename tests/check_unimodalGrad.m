function check_unimodalGrad

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