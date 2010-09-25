% mtimesx_build compiles mtimesx.c with BLAS libraries
%******************************************************************************
% 
%  MATLAB (R) is a trademark of The Mathworks (R) Corporation
% 
%  Function:    mtimesx_build
%  Filename:    mtimesx_build.m
%  Programmer:  James Tursa
%  Version:     1.10
%  Date:        February 15, 2010
%  Copyright:   (c) 2009, 2010 by James Tursa, All Rights Reserved
%
%  This code uses the BSD License:
%
%  Redistribution and use in source and binary forms, with or without 
%  modification, are permitted provided that the following conditions are 
%  met:
%
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%      
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%  POSSIBILITY OF SUCH DAMAGE.
%
%--
% 
%  mtimesx_build compiles mtimesx.c and mtimesx_RealTimesReal.c with the BLAS
%  libraries libmwblas.lib (if present) or libmwlapack.lib (if libmwblas.lib
%  is not present). This function basically works as follows:
%
%  - Opens the current mexopts.bat file in the directory [prefdir], and
%    checks to make sure that the compiler selected is cl or lcc. If it
%    is not, then a warning is issued and the compilation continues with
%    the assumption that the microsoft BLAS libraries will work.
%
%  - Looks for the file libmwblas.lib or libmwlapack.lib files in the
%    appropriate directory: [matlabroot '\extern\lib\win32\microsoft']
%                       or  [matlabroot '\extern\lib\win32\lcc']
%                       or  [matlabroot '\extern\lib\win64\microsoft']
%                       or  [matlabroot '\extern\lib\win64\lcc']
%
%  - Changes directory to the directory of the file mtimesx.m.
%
%  - Compiles mtimesx.c (which includes mtimesx_RealTimesReal.c) along with
%    either libmwblas.lib or libmwlapack.lib depending on the version of
%    MATLAB. The resulting exedcutable mex file is placed in the same
%    directory as the source code. The files mtimesx.m, mtimesx.c, and
%    mtimesx_RealTimesReal.c must all be in the same directory.
%
%  - Changes the directory back to the original directory.
%
%  Change Log:
%  2009/Sep/27 --> 1.00, Initial Release
%  2010/Feb/15 --> 1.10, Fixed largearrardims typo to largeArrayDims
%
%**************************************************************************

function mtimesx_build
disp(' ');
disp('... Build routine for mtimesx');

TRUE = 1;
FALSE = 0;

%\
% Check for number of inputs & outputs
%/

if( nargin ~= 0 )
    error('Too many inputs. Expected none.');
end
if( nargout ~= 0 )
    error('Too many outputs. Expected none.');
end

%\
% Check for non-PC
%/

disp('... Checking for PC');
try
    % ispc does not appear in MATLAB 5.3
    pc = ispc ;
catch
    % if ispc fails, assume we are on a Windows PC if it's not unix
    pc = ~isunix ;
end

if( ~pc )
    disp('Non-PC auto build is not currently supported. You will have to');
    disp('manually compile the mex routine. E.g., as follows:');
    disp(' ');
    disp('>> blas_lib = ''the_actual_path_and_name_of_your_systems_BLAS_library''');
    disp('>> mex(''-DDEFINEUNIX'',''mtimesx.c'',blas_lib)');
    disp(' ');
    disp('or');
    disp(' ');
    disp('>> mex(''-DDEFINEUNIX'',''-largeArrayDims'',''mtimesx.c'',blas_lib)');
    disp(' ');
    error('Unable to compile mtimesx.c');
end

%\
% Check to see that mtimesx.c source code is present
%/

disp('... Finding path of mtimesx C source code files');
try
    mname = mfilename('fullpath');
catch
    mname = mfilename;
end
cname = [mname(1:end-6) '.c'];
if( isempty(dir(cname)) )
    disp('Cannot find the file mtimesx.c in the same directory as the');
    disp('file mtimesx_build.m. Please ensure that they are in the same');
    disp('directory and try again. The following file was not found:');
    disp(' ');
    disp(cname);
    disp(' ');
    error('Unable to compile mtimesx.c');
end
disp(['... Found file mtimesx.c in ' cname]);

%\
% Check to see that mtimesx_RealTimesReal.c source code is present
%/

rname = [mname(1:end-13) 'mtimesx_RealTimesReal.c'];
if( isempty(dir(rname)) )
    disp('Cannot find the file mtimesx_RealTimesReal.c in the same');
    disp('directory as the file mtimesx_build.m. Please ensure that');
    disp('they are in the same directory and try again. The');
    disp('following file was not found:');
    disp(' ');
    disp(rname);
    disp(' ');
    error('Unable to compile mtimesx.c');
end
disp(['... Found file mtimesx_RealTimesReal.c in ' rname]);

%\
% Open the current mexopts.bat file
%/

mexopts = [prefdir '\mexopts.bat'];
fid = fopen(mexopts);
if( fid == -1 )
    error('A C/C++ compiler has not been selected with mex -setup');
end
disp(['... Opened the mexopts.bat file in ' mexopts]);

%\
% Check for the correct compiler selected.
%/

ok_cl = FALSE;
ok_lcc = FALSE;
while( TRUE )
    tline = fgets(fid);
    if( isequal(tline,-1) )
        break;
    else
        x = findstr(tline,'COMPILER=lcc');
        if( ~isempty(x) )
            disp('... lcc is the selected compiler');
            ok_lcc = TRUE;
            libdir = 'lcc';
            break;
        end
        x = findstr(tline,'COMPILER=cl');
        if( ~isempty(x) )
            disp('... MS Visual C/C++ is the selected compiler');
            ok_cl = TRUE;
            libdir = 'microsoft';
            break;
        end
        x = findstr(tline,'COMPILER=bcc32');
        if( ~isempty(x) )
            disp('... Borland C/C++ is the selected compiler');
            disp('... Assuming that Borland will link with Microsoft libraries');
            ok_cl = TRUE;
            libdir = 'microsoft';
            break;
        end
        x = findstr(tline,'COMPILER=icl');
        if( ~isempty(x) )
            disp('... Intel C/C++ is the selected compiler');
            disp('... Assuming that Intel will link with Microsoft libraries');
            ok_cl = TRUE;
            libdir = 'microsoft';
            break;
        end
        x = findstr(tline,'COMPILER=wc1386');
        if( ~isempty(x) )
            disp('... Watcom C/C++ is the selected compiler');
            disp('... Assuming that Watcom will link with Microsoft libraries');
            ok_cl = TRUE;
            libdir = 'microsoft';
            break;
        end
        x = findstr(tline,'COMPILER=gcc');
        if( ~isempty(x) )
            disp('... GCC C/C++ is the selected compiler');
            disp('... Assuming that GCC will link with Microsoft libraries');
            ok_cl = TRUE;
            libdir = 'microsoft';
            break;
        end
    end
end
fclose(fid);

%\
% MS Visual C/C++ or lcc compiler has not been selected
%/

if( ~(ok_cl | ok_lcc) )
    warning('... Supported C/C++ compiler has not been selected with mex -setup');
    warning('... Assuming that Selected Compiler will link with Microsoft libraries');
    warning('... Continuing at risk ...');
    libdir = 'microsoft';
end

%\
% Construct full file name of libmwblas.lib and libmwlapack.lib. Note that
% not all versions have both files. Earlier versions only had the lapack
% file, which contained both blas and lapack routines.
%/

comp = computer;
mext = mexext;
lc = length(comp);
lm = length(mext);
cbits = comp(max(1:lc-1):lc);
mbits = mext(max(1:lm-1):lm);
if( isequal(cbits,'64') | isequal(mbits,'64') )
    compdir = 'win64';
    largearraydims = '-largeArrayDims';
else
    compdir = 'win32';
    largearraydims = '';
end

lib_blas = [matlabroot '\extern\lib\' compdir '\' libdir '\libmwblas.lib'];
d = dir(lib_blas);
if( isempty(d) )
    disp('... BLAS library file not found, so linking with the LAPACK library');
    lib_blas = [matlabroot '\extern\lib\' compdir '\' libdir '\libmwlapack.lib'];
end
disp(['... Using BLAS library ' lib_blas]);

%\
% Save old directory and change to source code directory
%/

cdold = cd;
if( length(mname) > 13 )
    cd(mname(1:end-13));
end

%\
% Do the compile
%/

disp('... Now attempting to compile ...');
disp('... Note: Older versons of MATLAB may get lots of errors at this step because');
disp('          mwSize and mwSignedIndex are not defined. You can ignore these errors');
disp('          for now and this build routine will try to define them later.)');
disp(' ');
disp(['mex(''' cname ''',lib_blas)']);
disp(' ');
try
    if( isunix )
        if( isempty(largearraydims) )
            mex('-DDEFINEUNIX',cname,lib_blas);
        else
            mex('-DDEFINEUNIX',largearraydims,cname,lib_blas);
        end
    else
        if( isempty(largearraydims) )
            mex(cname,lib_blas);
        else
            mex(cname,largearraydims,lib_blas);
        end
    end
    disp('... mex mtimesx.c build completed ... you may now use mtimesx.');
    disp(' ');
catch
    disp(' ');
    disp('... Well, *that* didn''t work!');
    disp('... Now trying it with mwSize etc explicitly defined ...');
    disp(' ');
    try
        disp(' ');
        disp(['mex(''-DDEFINEMWSIZE'',''-DEFINEMWSIGNEDINDEX'',''' cname ''',lib_blas)']);
        disp(' ');
        if( isunix )
            if( isempty(largearraydims) )
                mex('-DDEFINEUNIX','-DDEFINEMWSIZE','-DDEFINEMWSIGNEDINDEX',cname,lib_blas);
            else
                mex('-DDEFINEUNIX','-DDEFINEMWSIZE','-DDEFINEMWSIGNEDINDEX',largearraydims,cname,lib_blas);
            end
        else
            if( isempty(largearraydims) )
                mex('-DDEFINEMWSIZE','-DDEFINEMWSIGNEDINDEX',cname,lib_blas);
            else
                mex('-DDEFINEMWSIZE','-DDEFINEMWSIGNEDINDEX',largearraydims,cname,lib_blas);
            end
        end
        disp('... mex mtimesx.c build completed ... you may now use mtimesx.');
        disp(' ');
    catch
        disp('... Hmmm ... That didn''t work either.');
        disp(' ');
        disp('The mex command failed. This may be because you have already run');
        disp('mex -setup and selected a non-C compiler, such as Fortran. If this');
        disp('is the case, then rerun mex -setup and select a C/C++ compiler.');
        disp(' ');
        cd(cdold);
        error('Unable to compile mtimesx.c');
    end
end

%\
% Restore old directory
%/

cd(cdold);

return
end
