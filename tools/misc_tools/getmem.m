function m = getmem
% return total system memory in kb

[r,s] = system('free');

m = sscanf(s(strfind(s,'Mem:')+5:end),'%d',1);
