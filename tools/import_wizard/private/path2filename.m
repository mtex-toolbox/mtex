function fnames = path2filename(arg)

fnames = arg;

if ~isempty(arg)
  if iscell(arg)
    for i=1:length(arg)
      n = regexp(arg{i},filesep);
      if ~isempty(n), fnames{i} = arg{i}((n(end)+1):end); end
    end  
  else
    n = regexp(arg,filesep);
    
    if ~isempty(n), fnames = arg((n(end)+1):end);end
  end
else
  fnames=blanks(0);
end