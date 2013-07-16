function m = getmem
% return total system memory in kb

try
  m = memory;
  m = m.MemAvailableAllArrays / 1024;
catch %#ok<CTCH>
  [r,s] = system('free');
  m = sscanf(s(strfind(s,'Mem:')+5:end),'%d',1);
  if isempty(m)
    m = 300 * 1024;
  end
  % reset error
  lasterr('');
end
end
