function mex_install(mtexpath,varargin)
% compiles all mex files for use with MTEX
%
% You need a mex Compiler for example MinGW64 for Windows 
%         --> Home/AddOns/Get Add-Ons ...
%


if nargin == 0, mtexpath = mtex_path;end

places = {'geometry/@S1Grid/private/S1Grid_',...
  'geometry/@S2Grid/private/S2Grid_',...
  'geometry/@SO3Grid/private/SO3Grid_',...
  'extern/insidepoly/',...
  'SO3Fun/@SO3FunHarmonic/private/adjoint',...
  'SO3Fun/@SO3FunHarmonic/private/representationbased'};
  

% compile all the files
for p = 1:length(places)
  files = dir([fullfile(mtexpath,places{p}),'*.c']);
  for f = 1:length(files)
    if ~files(f).isdir
      fName = fullfile(files(f).folder,files(f).name);
      disp(['... compiling ',files(f).name]);
      try
        mex('-R2018a',fName);
      catch %#ok<CTCH>
        if ~strfind(lasterr,'is not a MEX file.'), disp(lasterr); end
        %disp(['Compiling ' fName ' failed!']);
      end      
    end
  end
end
