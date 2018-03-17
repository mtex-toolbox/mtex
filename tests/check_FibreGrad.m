function check_FibreGrad

cs = crystalSymmetry('432');
ss = specimenSymmetry('222');

h = Miller.rand(cs);
r = vector3d.rand;

odf = fibreODF(h,r);

ori = orientation.rand(1000,cs,ss);

g1 = odf.grad(ori(:),'check','delta',0.1*degree);
g2 = odf.grad(ori(:));

if max(norm(g1-g2)./norm(g1)) < 1e-2
  disp(' Fibre gradient test passed'); 
else
  disp(' Fibre gradient test failed'); 
end

end