function result = verLessThan(tlbx,verstr)
% check matlab version 

MATLABver = ver(tlbx);

toolboxParts = getParts(MATLABver(1).Version);
verParts = getParts(verstr);

result = (sign(toolboxParts - verParts) * [1; .1; .01]) < 0;

function parts = getParts(V)
parts = sscanf(V, '%d.%d.%d')';

if length(parts) < 3
  parts(3) = 0; % zero-fills to 3 elements

end

