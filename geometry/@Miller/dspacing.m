function dspace = dspacing(h)
% space between crystal planes



a = get(h.CS,'axis');
V  = dot(a(1),cross(a(2),a(3)));
aa = cross(a(2),a(3)) ./ V;
bb = cross(a(3),a(1)) ./ V;
cc = cross(a(1),a(2)) ./ V;

hkl = v2m(h);
h = hkl(:,1) * aa + hkl(:,2) * bb + hkl(:,3) * cc;

dspace = 1./norm(h);

floor(dspace/2)+1




