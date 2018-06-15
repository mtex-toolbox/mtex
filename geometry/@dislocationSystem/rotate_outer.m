function dS = rotate_outer(dS,ori)
% rotate dislocation systems

dS.b = rotate_outer(dS.b,ori);
dS.l = rotate_outer(dS.l,ori);

dS.u = repmat(dS.u(:).',length(ori),1);

end