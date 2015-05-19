function m = getmem
% return total system memory in kb

try   
  m = memory;
  m = m.MemAvailableAllArrays / 1024;
catch %#ok<CTCH>
  [r,s] = system('free');
  m = sscanf(s(strfind(s,'Mem:')+5:end),'%d',3);
  if isempty(m)
    m = sscanf(s(strfind(s,'Speicher:')+9:end),'%d',3);
  end
  if isempty(m)
    m = 300 * 1024;
  else
    m = m(3);
  end
  % reset error
  lasterr('');
end
end
