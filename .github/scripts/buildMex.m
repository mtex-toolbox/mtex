% build every mex MTEX compiles itself, for the platform this is running on
%
% Driven by .github/workflows/build-mex.yml. Run from the repository root.
%
% The binaries for this platform are removed first, so that a source which
% fails to compile leaves a hole check_mexComplete can see rather than an
% older binary that silently passes for a fresh one. Only the files
% mex_install builds are touched - the NFFT family (nfftmex, nfsftmex,
% nfsoftmex, fptmex, and the lib* on macOS) is precompiled by the NFFT
% project, is not in mex_install's list, and has to survive into the
% uploaded artifact untouched.

addpath(pwd);
startup_mtex;

src = mex_install('list');
fprintf('%d mex sources to build for %s\n\n', numel(src), mexext);

removed = 0;
for k = 1:numel(src)
  [~,name] = fileparts(src{k});
  binary = fullfile(mtex_path,'mex',[name '.' mexext]);
  if isfile(binary)
    delete(binary);
    removed = removed + 1;
  end
end
fprintf('removed %d existing %s binaries\n\n', removed, mexext);

mex_install('force');

fprintf('\n');
check_mexComplete;
