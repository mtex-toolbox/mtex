function older=newer_version(ver)
% check matlab version 

v = version;
older = ver <= str2double(v(1:3));