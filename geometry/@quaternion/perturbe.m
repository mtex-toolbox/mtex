function q = perturbe(q,eps)
% pertube data randomly by epsilon

odf_pertube = unimodalODF(idquaternion,'halfwidth',eps);
ebsd = calcEBSD(odf_pertube,length(q));
q = reshape(ebsd.rotations,size(q)) .* q;
