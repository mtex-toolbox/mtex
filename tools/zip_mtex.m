function zip_mtex(outputFolder)
% zip mtex for publishing (on website)

if nargin < 1
  outputFolder = fileparts(mtex_path);
end

% name of the zip-file
verRev = getCurrentVerRevStr();
zipName = ['mtex-' verRev];
zipLocation = fullfile(outputFolder,zipName);

% files to exclude from zip
excludeFilter = {'.svn','.asv','.o',...
  ['help' filesep 'tmp'],...
  ['help' filesep 'html']};

relativePath = @(path) regexprep(path, regexptranslate('escape',[mtex_path filesep]),'');
filter = regexptranslate('escape',excludeFilter);
isValid = @(file) all(cellfun('isempty',regexpi(file,filter)));

packList = {};
for currentDir=getSubDirs(mtex_path)
  files = dir(currentDir{:});
  relPath = relativePath(currentDir{:});

  for l = find(~[files.isdir])
    file = fullfile(relPath,files(l).name);
    if isValid(file)
      packList{end+1} = file;
    end
  end
end

zip(zipLocation,packList,mtex_path);
disp(['zipped to ''' zipLocation '.zip'''])


function verRev = getCurrentVerRevStr()

rev = 0;
% for subDir=getSubDirs(mtex_path)
svnVersionFile = fullfile(mtex_path,'.svn','entries');

fid = fopen(svnVersionFile,'r');
if fid>0
  for k=1:3 , fgetl(fid); end;
  rev = max(str2num(fgetl(fid)),rev);
  fclose(fid);
end
% end

verRev = strtrim(regexprep(lower(getMTEXpref('version')),'mtex',''));
if rev > 0
  verRev = [verRev '.' num2str(rev)];
end

function dirs = getSubDirs(root)
dirs = {root};
file = dir(root);
file = file([file.isdir] & ~strncmp({file.name},'.',1));

% search subdirectories
for k=1:length(file)
  dirs = [dirs getSubDirs(fullfile(root,file(k).name))];
end
