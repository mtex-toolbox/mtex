function lookup = calcLookUp(DSO3,res)
% compute lookup table

[max_phi1,max_Phi,max_phi2] = fundamentalRegionEuler(DSO3.CS,DSO3.SS);

phi1 = 0:res:max_phi1;
Phi = 0:res:max_Phi;
phi2 = 0:res:max_phi2;

[phi1,Phi,phi2] = ndgrid(phi1,Phi,phi2);

ori = orientation.byEuler(phi1,Phi,phi2);

lookup = int32(reshape(DSO3.findTetra(ori),size(ori)));

end
