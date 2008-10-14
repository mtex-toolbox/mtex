function  [max_phi1,max_Phi,max_phi2] = getFundamentalRegion(cs,ss)
% get the fundamental region for a crystal and specimen symmetry

if rotangle_max_y(cs) == pi && rotangle_max_y(ss) == pi
  max_phi1 = pi/2;
else
  max_phi1 = rotangle_max_z(ss);
end
max_phi2=rotangle_max_z(cs);
max_Phi = min(rotangle_max_y(cs),rotangle_max_y(ss))/2;
