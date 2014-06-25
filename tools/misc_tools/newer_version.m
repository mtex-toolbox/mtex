function older = newer_version(v)
% check matlab version 

v1 = version;

n1 = sscanf(v1,'%d.%d');
n1 = n1(1) * 100 + n1(2);

if isa(v,'char')
  
  n2 = sscanf(v,'%d.%d');
  n2 = n2(1) * 100 + n2(2);

else
  
  n2 = fix(v) * 100 + (v-fix(v))*10;
  
end

older = n2 <= n1;