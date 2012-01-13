function fnames = path2filename(arg)

if ~isempty(arg)
  if iscell(arg)
    for i=1:length(arg)
      n = regexp(arg{i},filesep);
      fnames{i} = arg{i}((n(end)+1):end);
    end  
  else
    n = regexp(arg,filesep);
    fnames = arg((n(end)+1):end);
  end
else fnames=blanks(0);
end