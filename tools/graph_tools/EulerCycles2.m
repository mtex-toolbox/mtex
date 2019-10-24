function [cycles,Fid] = EulerCycles2(F)
%
% Syntax
%   [cycles,Fid] = EulerCycles2(F)
%
% Input
%  F - nx2 matrix of vertices
% Output
%
%  cycles -  
%  Fid    -

[~,ind,FF] = unique(F);
FF = reshape(FF,[],2);

A = sparse(FF(:,1),FF(:,2),1:length(F),max(FF(:)),max(FF(:)));
A = A + A.';

if isempty(F), return; end

% start with the first line
current = find(A,1);
cycles = current;
Fid = [];

while 1
   
  next = find(A(:,current),1,'first');
  
  if isempty(next)
    
    [current,next] = find(A,1);
    if isempty(current), break; end
    cycles = [cycles,NaN,next,current];
    Fid = [Fid,NaN,NaN,A(next,current)];
    A(next,current) = 0;
    A(current,next) = 0;
    
  else
    cycles(end+1) = next;
    Fid(end+1) = A(next,current);
    A(next,current) = 0;
    A(current,next) = 0;
    current = next;    
  end
  
end

cycles(~isnan(cycles)) = F(ind(cycles(~isnan(cycles))));

end