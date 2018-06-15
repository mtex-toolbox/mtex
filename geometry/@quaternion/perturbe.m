function q = perturbe(q,eps)
% pertube data randomly by epsilon

odf_pertube = unimodalODF(quaternion.id,'halfwidth',eps);
ebsd = calcEBSD(odf_pertube,length(q));
q = reshape(ebsd.rotations,size(q)) .* q;
