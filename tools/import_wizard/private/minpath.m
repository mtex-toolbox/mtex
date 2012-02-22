function [pname, fnames] = minpath(fnames)

if strcmp(fnames{1}(1),filesep)
  pname = filesep;
else
  pname = '';
end

b=true;

while b
  for i=1:length(fnames)
    [pn{i}, fnames{i}] = strtok( fnames{i},filesep);
  end
  b = all(strcmp(pn(1),pn(2:end))) && ~isempty(fnames{1});
  if b,
    if length(pname)>1, pname = strcat(pname,filesep);end
    pname = strcat(pname, pn{1});
  else
    pname =  strcat(pname, filesep);
    fnames = strcat(pn, fnames) ;
  end
end
