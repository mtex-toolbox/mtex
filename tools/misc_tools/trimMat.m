function B = trimMat(A)

c = any(A,1);
cMin = find(c,1,"first");
cMax = find(c,1,"last");

r = any(A(:,cMin:cMax),2);
rMin = find(r,1,"first");
rMax = find(r,1,"last");

B = A(rMin:rMax,cMin:cMax);
