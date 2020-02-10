function insidepoly_install
% function insidepoly_install
% Installation by building the C-mex files for insidepoly
%
% Author Bruno Luong <brunoluong@yahoo.com>
% Last update: 04-Jun-2010

arch=computer('arch');
mexopts = {'-O' '-v' ['-' arch]};
% 64-bit platform
if ~isempty(strfind(computer(),'64'))
    mexopts(end+1) = {'-largeArrayDims'};
end

% invoke MEX compilation tool
mex(mexopts{:},'insidepoly_dblengine.c');
mex(mexopts{:},'insidepoly_sglengine.c');