function makeRelease(ver)

% Every git command below belongs to the MTEX repository, so change into it
% before the first one. This pull used to run in whatever folder MATLAB
% happened to be in - usually not this one - where it would either rebase an
% unrelated repository or, more often, stop on that repository's uncommitted
% changes while makeRelease carried on regardless.
cd(mtex_path)

% ensure the tree is clean and up to date
ensureClean

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


% gh stores its token in the system keyring, so a login normally already
% exists and running one on every release was pointless. Only its absence
% needs an interactive terminal - the one thing that cannot be done from
% MATLAB - so ask for it rather than depending on a particular terminal
% emulator being installed and behaving.
disp('checking the GitHub authentication ...')
if system('gh auth status > /dev/null 2>&1') ~= 0
  error('makeRelease:notAuthenticated', ...
    ['not logged in at GitHub.\n\nRun\n\n  gh auth login\n\n' ...
    'in a terminal and start makeRelease again.']);
end

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
sh(doRelease,'creating the release draft');

% Hand over to CI, which builds the mex files for every platform, uploads them
% onto this draft and only then publishes it. Dispatched explicitly rather
% than triggered by the release, because a draft fires no release event.
%
% This needs the tag to be on the remote already, which the git push above
% did - if that silently failed, this is where it surfaces.
buildMex = ['gh workflow run build-mex.yml --ref ' ver ...
  ' -f release_tag=' ver];

disp('starting the mex build on GitHub ...')
sh(buildMex,'dispatching the mex build');

disp(' ')
disp('The release is a DRAFT until the mex build has finished.')
disp('Watch it with:  gh run list --workflow=build-mex.yml')
disp('If a platform fails the release stays a draft - fix it and dispatch')
disp('again, or publish by hand with:')
disp(['  gh release edit ' ver ' --draft=false'])

end

% ===========================================================================
function ensureClean
% pull, and refuse to build a release out of a dirty working tree
%
% The zip is a copy of the working tree, so an uncommitted edit would be
% shipped without ever having been pushed. Reporting that here beats finding
% it in the released zip. Checked before the pull, because a dirty tree is
% also what makes the pull itself fail under pull.rebase.

[~,out] = system('git status --porcelain');
if ~isempty(strtrim(out))
  error('makeRelease:dirtyTree', ...
    ['the MTEX working tree has uncommitted changes:\n\n%s\n' ...
    'Commit or stash them before releasing - the release zip is a copy ' ...
    'of this tree.'],out);
end

sh('git pull','updating the repository');

end

% ===========================================================================
function sh(cmd,what)
% run a shell command, keep its output visible, and stop if it fails
%
% Replaces the terminator calls this used to make. Spawning a terminal
% emulator was unreliable in two ways: it depends on that one emulator being
% installed, and the window takes the exit code away with it, so a release
% that failed to upload looked exactly like one that succeeded.
%
% MATLAB streams a command's output to the command window as long as only the
% status is requested, so the progress of a long upload stays visible.

disp(['  ' cmd])

% gh paints its output with ANSI escapes and asks the terminal for its
% background colour to pick a theme; in the command window both arrive as
% unreadable noise around the text that matters.
oldNoColor = getenv('NO_COLOR');
setenv('NO_COLOR','1');
restoreNoColor = onCleanup(@() setenv('NO_COLOR',oldNoColor)); %#ok<NASGU>

if system(cmd) ~= 0
  error('makeRelease:commandFailed','%s failed:\n\n  %s\n',what,cmd);
end

end
