function makeRelease

% ensure we are up to data
system("git pull");

ver = input("Enter Name of Version (default=" + getMTEXpref('version') + "): ",'s');

if isempty(ver)
  ver = getMTEXpref('version');
elseif length(ver)<5
  return
else
  setMTEXpref("version",ver)
end

% change to mtex path
cd(mtex_path)

% store new version file
fid = fopen("VERSION","w");
fprintf(fid,ver);
fclose(fid);

ver = strrep(lower(ver),' ','-');

% commit and push new version file
system("git commit VERSION -m """ + ver + """");
system("git tag -a " + ver + " -m ""Release of " + ver + """");
system("git push")

rDir = fullfile(mtex_path,'..','releases',ver);
zipName = [rDir,'.zip'];

unix(['rm -rf ',rDir]);
unix(['cp -R ' mtex_path ' ' rDir]);

rmList = {'doc/makeDoc/tmp', 'myToken.txt', 'data/*.mat' '.git*' ...
  'data/EBSD/*' '.mailmap' 'gitTricks.md' 'makeRelease.m' ...
  'mex/*.mex*'};
for rd = rmList 
  unix(['rm -rf ' rDir filesep char(rd)]); 
end

if any(strfind(ver,'beta'))
  unix(['rm -rf ' rDir filesep 'doc/html/*']);
  mkdir([rDir filesep 'doc/html/helpsearch-v3/']);
end

unix(['chmod -R a+rX ' rDir]);

% delete backup files
unix(['find ' rDir ' -name ''*~'' -or -name ''*.log'' -or -name ''*.o'' '...
  '-or -name ''*.orig'' -or -name ''.directory'' | xargs /bin/rm -rf']);

% delete old zip
unix(['rm -rf ' rDir '.zip']);

% create new zip
disp('compressing release ...')
zip(zipName,rDir);


disp('Authenticate at Github ...')
unix('terminator -e "gh auth login"');
% gh auth login

%doRelease = ['gh release create ' ver ' ' zipName ' -t "' getMTEXpref('version') '"'];
doRelease = ['gh release create ' ver ' ' zipName];
if any(strfind(ver,'beta')), doRelease = [doRelease,' -p']; end

disp('uploading release to GitHub ...')
disp('')
disp(doRelease)
unix(['terminator -e "' doRelease '"']);

end
