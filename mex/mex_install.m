function mex_install(varargin)
% compiles all mex files for use with MTEX
%
% You need a mex Compiler for example MinGW64 for Windows 
%         --> Home/AddOns/Get Add-Ons ...
%


places = {'geometry/@S1Grid/private/S1Grid_',...
  'geometry/@S2Grid/private/S2Grid_',...
  'geometry/@SO3Grid/private/SO3Grid_',...
  'extern/insidepoly/',...
  'extern/jcvoronoi/',...
  'extern/libDirectional/numerical',...
  'SO3Fun/@SO3FunHarmonic/private/wignerTrafo',...
  'tools/graph_tools/EulerCyclesC',...
  'interfaces/'
  };
  
% TODO: Check for mex-Compiler

mexPath = [mtex_path filesep 'mex'];

% compile all the files
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
        catch
          if ~contains(lasterr,'is not a MEX file.'), disp(lasterr); end %#ok<LERR>
        end
      else
        disp([' * <a href="matlab:edit ' cFile '">' ...
          files(f).name '</a> is up to data']);
      end
    end
  end
end
end
