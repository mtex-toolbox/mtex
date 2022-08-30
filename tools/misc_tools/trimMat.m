function B = trimMat(A)

cMin = find(any(A,1),1,"first");
cMax = find(any(A,1),1,"last");
rMin = find(any(A,2),1,"first");
rMax = find(any(A,2),1,"last");

B = A(rMin:rMax,cMin:cMax);
