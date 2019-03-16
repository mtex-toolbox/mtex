function fname = getFileNames(fname)
% get file names

% read in directory if needed
if ~iscell(fname), fname = char(fname); end
if ischar(fname)
  if exist(fname,'dir')
    pname = fname;
  else
    pname = fileparts(fname);
  end
  files = dir(fname);
  files = files(~[files.isdir]);
  assert(~isempty(files),'No file found!');
  if ~isempty(pname) && pname(end)~=filesep, pname = [pname,filesep];end
  fname = strcat(pname,{files.name});
end
