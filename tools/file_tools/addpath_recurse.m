function addpath_recurse(strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug)
%ADDPATH_RECURSE  Adds (or removes) the specified directory and its subfolders
% addpath_recurse(strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug)
%
% By default, all hidden directories (preceded by '.'), overloaded method directories
% (preceded by '@'), and directories named 'private' or 'CVS' are ignored.
%
% Input Variables
% ===============
% strStartDir::
%   Starting directory full path name.  All subdirectories (except ignore list) will be added to the path.
%   By default, uses current directory.
% caStrsIgnoreDirs::
%   Cell array of strings specifying directories to ignore.
%   Will also ignore all subdirectories beneath these directories.
%   By default, empty list. i.e. {''}.
% strXorIntAddpathMode::
%   Addpath mode, either 0/1, or 'begin','end'.
%   By default, prepends.
% blnRemDirs::
%   Boolean, when true will run function "in reverse", and 
%   recursively removes directories from starting path.
%   By default, false.
% blnDebug::
%   Boolean, when true prints debug info.
%   By default, false.
%
% Output Variables
% ================
% None. If blnDebug is specified, diagnostic information will print to the screen.
%
% Example(s)
% ==========
% (1) addpath_recurse();                                      %Take all defaults. 
% (2) addpath_recurse('strStartDir');                         %Start at 'strStartDir', take other defaults. i.e. Do addpath().
% (3) addpath_recurse('strStartDir', '', 0, true);            %Start at 'strStartDir', and undo example (2). i.e. Do rmpath().
% (4) addpath_recurse('strStartDir', '', 'end', false, true); %Do example (2) again, append to path, and display debug info.
% (5) addpath_recurse('strStartDir', '', 1, true, true);      %Undo example (4), and display debug info.

%
% See Also
% ========
% addpath()
%
% Developers
% ===========
% Init  Name             Contact
% ----  ---------------  ---------------------------------------------
% AK    Anthony Kendall  anthony [dot] kendall [at] gmail [dot] com
% JMcD  Joe Mc Donnell   
%
% Modifications
% =============
% Version   Date      Who    What
% --------  --------  -----  --------------------------------------------------------------------
% 00.00.00  20080808  AK     First created.
%           20090410  JMcD   Redo input argument processing/checking.
%                            Only do processing/checking once. Do recursion in separate function.
%           20090411  JMcD   Add debugging mode to display run info.
%           20090414  AK     Modified variable names, small edits to code, ignoring CSV by default
%           20091104  AK     Modified an optimization for Mac compatibility,
%                            recursive calls to just build the string for
%                            addpath/rmpath rather than call it each time

%--------------------------------------------------------------------------
%Error messages.
strErrStartDirNoExist = 'Start directory does not exist ???';
strErrIgnoreDirsType = 'Ignore directories must be a string or cell array. See HELP ???';
strErrIllAddpathMode = 'Illegal value for addpath() mode.  See HELP ???';
strErrIllRevRecurseRemType = 'Illegal value for reverse recurse remove, must be a logical/boolean.  See HELP ??';

strErrWrongNumArg = 'Wrong number of input arguments.  See HELP ???';
strAddpathErrMessage = strErrIllAddpathMode;

%Set input args defaults and/or check them.
intNumInArgs = nargin();
assert(intNumInArgs <= 5, strErrWrongNumArg);

if intNumInArgs < 1
 strStartDir = pwd();
end

if intNumInArgs < 2
  caStrsIgnoreDirs = {''};
end

if intNumInArgs >= 2 && ischar(caStrsIgnoreDirs)
  caStrsIgnoreDirs = { caStrsIgnoreDirs };
end

if intNumInArgs < 3 || (intNumInArgs >= 3 && isempty(strXorIntAddpathMode))
  strXorIntAddpathMode = 0;
end

if intNumInArgs >= 3 && ischar(strXorIntAddpathMode)  %Use 0/1 internally.
  strAddpathErrMessage = sprintf('Input arg addpath() mode "%s" ???\n%s', strXorIntAddpathMode, strErrIllAddpathMode);
  assert(any(strcmpi(strXorIntAddpathMode, {'begin', 'end'})), strAddpathErrMessage);
  strXorIntAddpathMode = strcmpi(strXorIntAddpathMode, 'end'); %When 'end' 0 sets prepend, otherwise 1 sets append.
end

if intNumInArgs < 4
  blnRemDirs = false;
end

if intNumInArgs < 5
  blnDebug = false;
end

if size(caStrsIgnoreDirs, 1) > 1
  caStrsIgnoreDirs = caStrsIgnoreDirs'; %Transpose from column to row vector, in theory.
end

%Check input args OK, before we do the thing.
strErrStartDirNoExist = sprintf('Input arg start directory "%s" ???\n%s', strStartDir, strErrStartDirNoExist);
assert(exist(strStartDir, 'dir') > 0, strErrStartDirNoExist);
assert(iscell(caStrsIgnoreDirs), strErrIgnoreDirsType);
assert(strXorIntAddpathMode == 0 || strXorIntAddpathMode == 1, strAddpathErrMessage);
assert(islogical(blnRemDirs), strErrIllRevRecurseRemType);
assert(islogical(blnDebug), 'Debug must be logical/boolean.  See HELP.');

if blnDebug
  intPrintWidth = 34;
  rvAddpathModes = {'prepend', 'append'};
  strAddpathMode = char(rvAddpathModes{ fix(strXorIntAddpathMode) + 1});
  strRevRecurseDirModes = { 'false', 'true' };
  strRevRecurseDirs = char(strRevRecurseDirModes{ fix(blnRemDirs) + 1 });
  strIgnoreDirs = '';
  for intD = 1 : length(caStrsIgnoreDirs)
    if ~isempty(strIgnoreDirs)
      strIgnoreDirs = sprintf('%s, ', strIgnoreDirs);
    end
    strIgnoreDirs = sprintf('%s%s', strIgnoreDirs, char(caStrsIgnoreDirs{intD}));
  end
  strTestModeResults = sprintf('... Debug mode, start recurse addpath arguments ...');
  strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'Start directory', strStartDir);
  strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'Ignore directories', strIgnoreDirs);
  strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'addpath() mode', strAddpathMode);
  strTestModeResults = sprintf('%s\n%*s: "%s"', strTestModeResults, intPrintWidth, 'Reverse recurse remove directories', strRevRecurseDirs);
  disp(strTestModeResults);
end

%Don't print the MATLAB warning if remove path string is not found
if blnRemDirs, warning('off', 'MATLAB:rmpath:DirNotFound'); end

%Build the list of directories
caAddRemDirs = {};
[caAddRemDirs] = addpath_recursively(caAddRemDirs, strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs,blnDebug);

%Remove or add the directory from the search path
if blnRemDirs
  if blnDebug, fprintf('"%s", removing from search path ...', strStartDir); end
  rmpath(caAddRemDirs{:})
else
  if blnDebug, fprintf('"%s", adding to search path ...', strStartDir); end
  addpath(caAddRemDirs{:}, strXorIntAddpathMode);
end

%Restore the warning state for rmpath
if blnRemDirs, warning('on', 'MATLAB:rmpath:DirNotFound'); end

end % function addpath_recurse
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function [caAddRemDirs] = addpath_recursively(caAddRemDirs, strStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug)
%Note:Don't need to check input arguments, because caller already has.

%Add this directory to the add/remove path list
caAddRemDirs = [caAddRemDirs,strStartDir];

strFileSep = filesep();
%Get list of directories beneath the specified directory, this two-step process is faster.
if ispc
    saSubDirs = dir(sprintf('%s%s%s', strStartDir, strFileSep, '*.'));
else
    saSubDirs = dir(strStartDir);
end
saSubDirs = saSubDirs([saSubDirs.isdir]); %Handles files without extensions that otherwise pass through previous filter

%Loop through the directory list and recursively call this function.
for intDirIndex = 1 : length(saSubDirs)
  strThisDirName = saSubDirs(intDirIndex).name;
  blnIgnoreDir = any(strcmpi(strThisDirName, { 'private', 'CVS', '.', '..', caStrsIgnoreDirs{:} }));
  blnDirBegins = any(strncmp(strThisDirName, {'@', '.'}, 1));
  if ~(blnIgnoreDir || blnDirBegins)
    strThisStartDir = sprintf('%s%s%s', strStartDir, strFileSep, strThisDirName);
    if blnDebug, fprintf('"%s", recursing ...', strThisStartDir); end
    [caAddRemDirs] = addpath_recursively(caAddRemDirs, strThisStartDir, caStrsIgnoreDirs, strXorIntAddpathMode, blnRemDirs, blnDebug);
  end
end % for each directory.

end % function addpath_recursively
%--------------------------------------------------------------------------
%__END__
