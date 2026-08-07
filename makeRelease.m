function makeRelease(ver)

% ensure we are up to data
system("git pull");

if nargin == 0
  ver = input("Enter Name of Version (default=" + getMTEXpref('version') + "): ",'s');
else
  if ~strcmpi(input(['Do you really want to release ' ver '? Y/N [N]:'],'s'),'Y')
    return;
  end
end



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
system("git push --tags")

rDir = fullfile(mtex_path,'..','releases',ver);
zipName = [rDir,'.zip'];

unix(['rm -rf ',rDir]);
unix(['cp -R ' mtex_path ' ' rDir]);

rmList = {'doc/makeDoc/tmp', 'myToken.txt', 'data/*.mat' '.git*' ...
  'data/EBSD/*' '.mailmap' 'gitTricks.md' 'makeRelease.m' ...
  'mex/*.mex*' '.claude' 'docs/agents/matlab-bridge/.venv' ...
  'docs/agents/matlab-bridge/session.*'};
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

% The release is created as a DRAFT and stays invisible until the build mex
% workflow has attached the binaries for all four platforms and published it.
% That ordering matters: the zip ships no mex files (see rmList above), so
% check_mex downloads them from the release assets on first start - and anyone
% installing between "release visible" and "binaries attached" would get a
% failed download and be told to compile them by hand.
%doRelease = ['gh release create ' ver ' ' zipName ' -t "' getMTEXpref('version') '"'];
doRelease = ['gh release create ' ver ' ' zipName ' --draft'];
if any(strfind(ver,'beta')), doRelease = [doRelease,' -p']; end

disp('uploading release draft to GitHub ...')
disp('')
disp(doRelease)
unix(['terminator -e "' doRelease '"']);

% Hand over to CI, which builds the mex files for every platform, uploads them
% onto this draft and only then publishes it. Dispatched explicitly rather
% than triggered by the release, because a draft fires no release event.
buildMex = ['gh workflow run build-mex.yml --ref ' ver ...
  ' -f release_tag=' ver];

disp('starting the mex build on GitHub ...')
disp('')
disp(buildMex)
unix(['terminator -e "' buildMex '"']);

disp(' ')
disp('The release is a DRAFT until the mex build has finished.')
disp('Watch it with:  gh run list --workflow=build-mex.yml')
disp('If a platform fails the release stays a draft - fix it and dispatch')
disp('again, or publish by hand with:')
disp(['  gh release edit ' ver ' --draft=false'])

end
