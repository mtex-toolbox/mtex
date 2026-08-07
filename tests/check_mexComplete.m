function varargout = check_mexComplete(varargin)
% every mex MTEX compiles itself must have a binary for the running platform
%
% Syntax
%   check_mexComplete
%   missing = check_mexComplete('quiet')
%
% Description
% mex_install reports a compile failure by printing it and carrying on, so a
% build can look successful while leaving binaries behind. This turns that
% into a pass or fail, which is what the build workflow gates on.
%
% Only the mex files MTEX builds from its own sources are checked. The NFFT
% family - nfftmex, nfsftmex, nfsoftmex, fptmex and the lib* on macOS - comes
% precompiled from the NFFT project, is not in mex_install's list and is not
% expected to be rebuilt here.
%
% Output
%  missing - names of the mex files with no binary for this platform
%
% Flags
%  quiet - return the list instead of raising an error
%
% See also
% mex_install check_mex

src = mex_install('list');

missing = {};
for k = 1:numel(src)
  [~,name] = fileparts(src{k});
  if ~isfile(fullfile(mtex_path,'mex',[name '.' mexext]))
    missing{end+1} = name; %#ok<AGROW>
  end
end

if nargout > 0, varargout{1} = missing; end

if check_option(varargin,'quiet'), return; end

if ~isempty(missing)
  error(['check_mexComplete: %d of %d mex files have no %s binary:\n  %s\n' ...
    'Run mex_install and read its output - it prints compile errors instead ' ...
    'of raising them.'], ...
    numel(missing), numel(src), mexext, strjoin(missing,'\n  '));
end

fprintf('check_mexComplete: all %d mex files present for %s\n',numel(src),mexext);

end
