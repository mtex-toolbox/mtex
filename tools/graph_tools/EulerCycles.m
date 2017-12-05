function poly = EulerCycles(F)
% retrieve Euler cycles from an not oriented edge list

% convert to consecute numbers
% now it remains to identify 1->2, 3->4, 5->6 and so on
[~,A] = sort(F(:));
B(A) = 1:numel(F);
B = reshape(B,[],2);

% index for B, i.e., B(iB(n)) == n
[~,iB] = sort(B(:));

numF = size(F,1);
polyB = zeros(numF,1); % these are positions in B
tourStart = 1;

if isempty(iB)
  poly = {};
  return;
end

currentiB = iB(1);  % starting vertex

for ipoly = 1:numF

  polyB(ipoly) = currentiB;
  currentB = B(currentiB)-1;
  iB(2*fix(currentB/2)+(1:2)) = 0; % do not visit this again
  
  if currentiB > numF
    nextB = B(currentiB - numF);
  else
    nextB = B(currentiB + numF);
  end
  
  if mod(nextB,2), nextB = nextB + 1; else nextB = nextB - 1; end
  
  currentiB = iB(nextB);
  
  if currentiB == 0 %start new cycle
    [~,~,currentiB] = find(iB,1);
    tourStart(end+1) = ipoly+1; %#ok<AGROW>
  end    

end

% entries of poly should be indeces of vertices
poly = F(polyB).';

numTours = numel(tourStart)-1;
polys = cell(1,numTours);
for k=1:numTours
  polys{k} = [poly(tourStart(k):tourStart(k+1)-1),poly(tourStart(k))];
end

if numTours == 1
  poly = polys;
else
  % order such that largest Tour is the first one
  [~,order] = sort(diff(tourStart),'descend');
  poly = polys(order);
end

end
