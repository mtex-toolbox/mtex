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

% the release is what the tag tracks. Anything a working session leaves in the
% folder - a built binary, a downloaded dataset, an editor backup, a virtualenv -
% is not in the tag and so cannot reach the zip.
unix(['mkdir -p ' rDir ' && git archive --format=tar ' ver ' | tar -x -C ' rDir]);

% of what is tracked, what a user of the zip has no use for: the datasets, which
% mtexdata downloads on demand, the mex binaries, which the build workflow
% attaches to the release, and the notes that name one machine
rmList = {'.github' '.gitignore' '.gitattributes' '.mailmap' 'gitTricks.md' ...
  'makeRelease.m' 'data/*.mat' 'data/EBSD/*' 'mex/*.mex*' ...
  'docs/agents' 'docs/doc-audit-plan.md' 'interfaces/import_wizard/TODO.md'};
for rd = rmList
  unix(['rm -rf ' rDir filesep char(rd)]);
end

unix(['chmod -R a+rX ' rDir]);

% delete old zip
unix(['rm -rf ' rDir '.zip']);

% create new zip
disp('compressing release ...')
zip(zipName,rDir);


% gh keeps its token in the keyring, so only its absence needs a terminal
disp('checking the GitHub authentication ...')
if system('gh auth status > /dev/null 2>&1') ~= 0
  error('makeRelease:notAuthenticated', ...
    ['not logged in at GitHub.\n\nRun\n\n  gh auth login\n\n' ...
    'in a terminal and start makeRelease again.']);
end

% create a draft, which stays invisible until the build mex workflow attached
% the binaries - title and notes are given, since gh prompts for what it lacks
doRelease = ['gh release create ' ver ' ' zipName ...
  ' --draft --verify-tag --generate-notes --title "' ver '"'];
if any(strfind(ver,'beta')), doRelease = [doRelease,' -p']; end

disp('uploading release draft to GitHub ...')
sh(doRelease,'creating the release draft');

% hand over to CI explicitly, a draft fires no release event
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
% The zip is built from the tag, so an uncommitted edit is left out of it
% silently - a fix that was meant to be in the release and is not. Checked
% before the pull, because a dirty tree is also what makes the pull itself
% fail under pull.rebase.

[~,out] = system('git status --porcelain');
if ~isempty(strtrim(out))
  error('makeRelease:dirtyTree', ...
    ['the MTEX working tree has uncommitted changes:\n\n%s\n' ...
    'Commit them before releasing - the release zip is built from the ' ...
    'tag, so anything uncommitted is left out of it.'],out);
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

% gh paints its output with ANSI escapes, which the command window cannot show
oldNoColor = getenv('NO_COLOR');
setenv('NO_COLOR','1');
restoreNoColor = onCleanup(@() setenv('NO_COLOR',oldNoColor)); %#ok<NASGU>

% close stdin, so that a command asking a question fails instead of hanging
if system([cmd ' < /dev/null']) ~= 0
  error('makeRelease:commandFailed','%s failed:\n\n  %s\n',what,cmd);
end

end
