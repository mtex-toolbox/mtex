function ebsd = loadEBSD_quaternion(fname, varargin)

d = dlmread(fname);
q = quaternion(d(:,3),d(:,4),d(:,5),d(:,6));
q = inverse(q);
ebsd = EBSD(q,symmetry('cubic'),symmetry(),'xy',d(:,[1 2]));
