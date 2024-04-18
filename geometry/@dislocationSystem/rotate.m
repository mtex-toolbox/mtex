function dS = rotate(dS,ori)
% rotate dislocation systems system

dS.b = rotate(dS.b,ori);
dS.l = rotate(dS.l,ori);

if isscalar(dS.u), dS.u = repmat(dS.u,size(dS.b)); end

end