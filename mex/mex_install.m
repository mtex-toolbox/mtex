function varargout = mex_install(varargin)
% compiles all mex files for use with MTEX
%
% You need a mex Compiler for example MinGW64 for Windows
%         --> Home/AddOns/Get Add-Ons ...
%
% Syntax
%   mex_install
%   mex_install('force')
%   src = mex_install('list')   % the sources that would be compiled
%
% Flags
%  force - recompile even where the binary is newer than the source
%  list  - do not compile, just return the source files as a cell array
%
% Description
% Compiling continues past a source that fails, so that one broken file
% does not hide the state of all the others, but the failures are collected
% and raised as an error at the end - a run that built nothing must not look
% like a run that built everything.
%
% See also
% check_mexComplete


places = {'geometry/@S1Grid/private/S1Grid_',...
  'geometry/@S2Grid/private/S2Grid_',...
  'geometry/@SO3Grid/private/SO3Grid_',...
  'extern/insidepoly/',...
  'extern/jcvoronoi/',...
  'extern/libDirectional/numerical',...
  'SO3Fun/@SO3FunHarmonic/private/wignerTrafo',...
  'SO3Fun/@SO3FunHarmonic/private/sphericalHarmonicTrafo',...
  'tools/graph_tools/EulerCyclesC',...
  'tools/graph_tools/chainOrderC',...
  'interfaces/'
  };
  
% TODO: Check for mex-Compiler

mexPath = [mtex_path filesep 'mex'];

% report the sources instead of compiling them - check_mexComplete and the
% build workflow ask for this rather than repeating the list above, which
% would go stale the moment a mex is added
if check_option(varargin,'list')
  varargout{1} = listSources(places);
  return
end

% compile all the files
failed = {};
for p = 1:length(places)
  files = dir([fullfile(mtex_path,places{p}),'*.c*']);
  for f = 1:length(files)
    if ~files(f).isdir
      cFile = fullfile(files(f).folder,files(f).name);

      [~,fName,~] = fileparts(files(f).name);
      mexFile = fullfile(mexPath,[fName '.' mexext]);
      mexFileD = dir(mexFile);

      if isempty(mexFileD) || check_option(varargin,'force') || ...
          mexFileD.datenum < files(f).datenum
        disp([' * <a href="matlab:edit ' cFile '">' ...
          files(f).name '</a> is compiling']);

        compFile = fullfile(files(f).folder,'compile.m');
        try
          if exist(compFile,"file")
            run(compFile)
            movefile(fullfile(files(f).folder,[fName '.' mexext]),mexFile,'f')
          else
            mex('-R2018a','-outdir',mexPath,cFile);
          end
        catch ME
          % a source that compiles but carries no mexFunction entry is not
          % a failure - it only exists to be included by one of the real
          % mex sources. Everything else is reported and remembered: a
          % build that quietly skipped half its files used to be
          % indistinguishable from a clean one.
          if ~contains(ME.message,'is not a MEX file.')
            failed{end+1} = files(f).name; %#ok<AGROW>
            fprintf(2,'   %s failed to compile:\n',files(f).name);
            fprintf(2,'   %s\n',ME.message);
          end
        end
      else
        disp([' * <a href="matlab:edit ' cFile '">' ...
          files(f).name '</a> is up to data']);
      end
    end
  end
end

if ~isempty(failed)
  error('MTEX:mex_install',['%d of %d mex files did not compile:\n  %s\n\n' ...
    'The compiler messages are above.'],numel(failed),numel(listSources(places)),...
    strjoin(failed,newline+"  "));
end

end

% ===========================================================================
function src = listSources(places)
% the source files the loop above would compile, in the same order

src = {};

for p = 1:length(places)
  files = dir([fullfile(mtex_path,places{p}),'*.c*']);
  for f = 1:length(files)
    if ~files(f).isdir
      src{end+1} = fullfile(files(f).folder,files(f).name); %#ok<AGROW>
    end
  end
end

src = src(:);

end
