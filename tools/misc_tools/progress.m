function progress(i,total,comment)
% display progress

global mtex_progress;
global prevCharCnt;

if ~isempty(mtex_progress) && ~mtex_progress, return;end

persistent p;

np = round(i/total*100);
if np < p
  prevCharCnt = 0;
elseif np == p
  return;
end
  
p = np;

if nargin <= 2, comment = 'progress: ';end

disptmp([comment int2str(p)  '%']);
