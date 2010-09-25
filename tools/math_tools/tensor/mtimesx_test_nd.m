% Test routine for mtimesx, multi-dimensional speed and equality to MATLAB
%******************************************************************************
% 
%  MATLAB (R) is a trademark of The Mathworks (R) Corporation
% 
%  Function:    mtimesx_test_nd
%  Filename:    mtimesx_test_nd.m
%  Programmer:  James Tursa
%  Version:     1.30
%  Date:        August 2, 2010
%  Copyright:   (c) 2009,2010 by James Tursa, All Rights Reserved
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
%  Syntax:
%
%    mtimesx_test_nd    % default n=3 is used
%    mtimesx_test_nd(n)
%
%    where n = number of repetitions (should be 3 or greater)
%
%  Output:
%
%    Prints out speed and equality test results.
%
%--------------------------------------------------------------------------

function mtimesx_test_nd(n)
mtimesx; % load the mex routine into memory
if( nargin == 0 )
    n = 3;
else
    n = floor(n);
    if( ~(n >= 3 && n <= 100) )
        n = 3;
    end
end
cn = sprintf('%g',n);

disp(' ');
disp('(M x K) * ( K x N) equality tests, SPEED mode, M,K,N <= 4');
trans = 'NGTC';
cmpx = {'real ','cmpx '};
mtimesx('speed');
smallok = true;
for m=1:4
    for k=1:4
        for n=1:4
            for transa=1:4
                if( transa <= 2 )
                    ma = m;
                    ka = k;
                else
                    ma = k;
                    ka = m;
                end
                for transb=1:4
                    if( transb <= 2 )
                        kb = k;
                        nb = n;
                    else
                        kb = n;
                        nb = k;
                    end
                    for cmplxa=1:2
                        if( cmplxa == 1 )
                            A = floor(rand(ma,ka)*100+1);
                        else
                            A = floor(rand(ma,ka)*100+1) + floor(rand(ma,ka)*100+1)*1i;
                        end
                        for cmplxb=1:2
                            if( cmplxb == 1 )
                                B = floor(rand(kb,nb)*100+1);
                            else
                                B = floor(rand(kb,nb)*100+1) + floor(rand(kb,nb)*100+1)*1i;
                            end
                            Cm = mtimesx_sparse(A,trans(transa),B,trans(transb));
                            Cx = mtimesx(A,trans(transa),B,trans(transb));
                            if( isequal(Cm,Cx) )
                                disp(['(' cmpx{cmplxa} num2str(m) ' x ' num2str(k) ')' trans(transa) ...
                                        ' * (' cmpx{cmplxb} num2str(k) ' x ' num2str(n) ')' trans(transb) '  EQUAL']);
                            else
                                disp(['(' cmpx{cmplxa} num2str(m) ' x ' num2str(k) ')' trans(transa) ...
                                        ' * (' cmpx{cmplxb} num2str(k) ' x ' num2str(n) ')' trans(transb) '  NOT EQUAL']);
                                smallok = false;
                            end
                        end
                    end
                end
            end
        end
    end
end

disp(' ');
if( smallok )
    disp('All small matrix multiplies are OK');
else
    disp('ERROR --> One or more of the small matrix multiplies was not equal');
end

disp(' ');
disp(['mtimesx multi-dimensional test routine using ' cn ' repetitions']);

disp(' ');
disp('(real 3x5x1x4x3x2x1x8) * (real 5x7x3x1x3x2x5) example');
A = rand(3,5,1,4,3,2,1,8);
B = rand(5,7,3,1,3,2,5);
% mtimes
tm = zeros(1,n);
for k=1:n
clear Cm Cx
A(1) = 2*A(1);
B(1) = 2*B(1);
tic
Cm = zeros(3,7,3,4,3,2,5,8);
for k1=1:3
    for k2=1:4
        for k3=1:3
            for k4=1:2
                for k5=1:5
                    for k6=1:8
                        Cm(:,:,k1,k2,k3,k4,k5,k6) = A(:,:,1,k2,k3,k4,1,k6) * B(:,:,k1,1,k3,k4,k5);
                    end
                end
            end
        end
    end
end
tm(k) = toc;
end
% mtimesx
tx = zeros(1,n);
for k=1:n
tic
Cx = mtimesx(A,B);
tx(k) = toc;
end
% results
tm = median(tm);
tx = median(tx);
faster = sprintf('%5.1f',100*(tm)/tx-100);
disp(' ');
disp(['mtimes  Elapsed time ' num2str(tm) ' seconds.']);
disp(['mtimesx Elapsed time ' num2str(tx) ' seconds.']);
disp(['mtimesx is ' faster '% faster than mtimes'])
if( isequal(Cx,Cm) )
    disp('mtimesx result matches mtimes:  EQUAL')
else
    disp('mtimesx result does not match mtimes:  NOT EQUAL')
end

disp(' ');
disp('(real 3x3x1000000) * (real 3x3x1000000) example');
A = rand(3,3,1000000);
B = rand(3,3,1000000);
% mtimes
tm = zeros(1,n);
for k=1:n
clear Cm Cx
A(1) = 2*A(1);
B(1) = 2*B(1);
tic
Cm = zeros(3,3,1000000);
for k1=1:1000000
    Cm(:,:,k1) = A(:,:,k1) * B(:,:,k1);
end
tm(k) = toc;
end
% mtimesx
tx = zeros(1,n);
for k=1:n
tic
Cx = mtimesx(A,B);
tx(k) = toc;
end
% results
tm = median(tm);
tx = median(tx);
faster = sprintf('%5.1f',100*(tm)/tx-100);
disp(' ');
disp(['mtimes  Elapsed time ' num2str(tm) ' seconds.']);
disp(['mtimesx Elapsed time ' num2str(tx) ' seconds.']);
disp(['mtimesx is ' faster '% faster than mtimes'])
if( isequal(Cx,Cm) )
    disp('mtimesx result matches mtimes:  EQUAL')
else
    disp('mtimesx result does not match mtimes:  NOT EQUAL')
end

disp(' ');
disp('(real 2x2x2000000) * (real 2x2x2000000) example');
A = rand(2,2,2000000);
B = rand(2,2,2000000);
% mtimes
tm = zeros(1,n);
for k=1:n
clear Cm Cx
A(1) = 2*A(1);
B(1) = 2*B(1);
tic
Cm = zeros(2,2,2000000);
for k1=1:2000000
    Cm(:,:,k1) = A(:,:,k1) * B(:,:,k1);
end
tm(k) = toc;
end
% mtimesx
tx = zeros(1,n);
for k=1:n
tic
Cx = mtimesx(A,B);
tx(k) = toc;
end
% results
tm = median(tm);
tx = median(tx);
faster = sprintf('%5.1f',100*(tm)/tx-100);
disp(' ');
disp(['mtimes  Elapsed time ' num2str(tm) ' seconds.']);
disp(['mtimesx Elapsed time ' num2str(tx) ' seconds.']);
disp(['mtimesx is ' faster '% faster than mtimes'])
if( isequal(Cx,Cm) )
    disp('mtimesx result matches mtimes:  EQUAL')
else
    disp('mtimesx result does not match mtimes:  NOT EQUAL')
end

disp(' ');
disp('(real 2x2x2000000) * (real 1x1x2000000) example');
A = rand(2,2,2000000);
B = rand(1,1,2000000);
% mtimes
tm = zeros(1,n);
for k=1:n
clear Cm Cx
A(1) = 2*A(1);
B(1) = 2*B(1);
tic
Cm = zeros(2,2,2000000);
for k1=1:2000000
    Cm(:,:,k1) = A(:,:,k1) * B(:,:,k1);
end
tm(k) = toc;
end
% mtimesx
tx = zeros(1,n);
for k=1:n
tic
Cx = mtimesx(A,B);
tx(k) = toc;
end
% results
tm = median(tm);
tx = median(tx);
faster = sprintf('%5.1f',100*(tm)/tx-100);
disp(' ');
disp(['mtimes  Elapsed time ' num2str(tm) ' seconds.']);
disp(['mtimesx Elapsed time ' num2str(tx) ' seconds.']);
disp(['mtimesx is ' faster '% faster than mtimes'])
if( isequal(Cx,Cm) )
    disp('mtimesx result matches mtimes:  EQUAL')
else
    disp('mtimesx result does not match mtimes:  NOT EQUAL')
end

try
bsxfun(@times,1,1);
A = rand(2,2,2000000);
B = rand(1,1,2000000);
% bsxfun
tm = zeros(1,n);
for k=1:n
clear Cm Cx
A(1) = 2*A(1);
B(1) = 2*B(1);
tic
Cm = bsxfun(@times,A,B);
tm(k) = toc;
end
% mtimesx
tx = zeros(1,n);
for k=1:n
tic
Cx = mtimesx(A,B);
tx(k) = toc;
end
% results
tm = median(tm);
tx = median(tx);
faster = sprintf('%5.1f',100*(tm)/tx-100);
disp(['bsxfun  Elapsed time ' num2str(tm) ' seconds.']);
disp(['mtimesx Elapsed time ' num2str(tx) ' seconds.']);
disp(['mtimesx is ' faster '% faster than bsxfun'])
if( isequal(Cx,Cm) )
    disp('mtimesx result matches bsxfun:  EQUAL')
else
    disp('mtimesx result does not match bsxfun:  NOT EQUAL')
end
catch
    disp('Could not perform comparison with bsxfun, possibly because your version of');
    disp('MATLAB does not have it. You can download a substitute for bsxfun from the');
    disp('FEX here: http://www.mathworks.com/matlabcentral/fileexchange/23005-bsxfun-substitute');
end

disp(' ');
disp('Done');
disp(' ');

end
