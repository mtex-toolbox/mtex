function testKAM2(grains, voronoiId, maxAngle)

%% Readjust indexes of A_D to the restrained set of voronois included 
% in the given grain set

A_D = get(grains, 'A_D');
b = find(any(get(grains, 'I_DG'), 2));
A_D = A_D(b,b);

% Select only voronois inside the grains
n = size(A_D,1);
I_FD = get(grains, 'I_FDext') | get(grains, 'I_FDsub');
[d,~] = find(I_FD(sum(I_FD,2) == 2, any(get(grains, 'I_DG'),2))');
Dl = d(1:2:end);
Dr = d(2:2:end);
A_D = A_D - sparse(Dl,Dr,1,n,n);
A_D = A_D | A_D';

A_D = double(A_D);

%% Find first neighbour

% A_D1 = nadjacent(A_D,1);
A_D1 = nadjacent(A_D,1) - nadjacent(A_D,0); % Last term optional

plotPoints(grains, voronoiId, maxAngle, A_D1, 's', 10);


%% Find second neighbour
% A_D2 = nadjacent(A_D,2);
A_D2 = nadjacent(A_D,2) - nadjacent(A_D,1);

plotPoints(grains, voronoiId, maxAngle, A_D2, '^', 20);

%% Find third neighbour

% A_D3 = nadjacent(A_D,3);
A_D3 = nadjacent(A_D,3) - nadjacent(A_D,2);

plotPoints(grains, voronoiId, maxAngle, A_D3, 'o', 30);

end

function plotPoints(grains, voronoiId, maxAngle, A_D, marker, markerSize) 

xs = get(grains, 'x');
ys = get(grains, 'y');
CS = get(grains,'CSCell');
SS = get(grains,'SS');
r = get(get(grains, 'EBSD'),'quaternion');
phaseMap = get(grains,'phaseMap');
phase = get(get(grains, 'EBSD'),'phase');
isIndexed = ~isNotIndexed(get(grains, 'EBSD'));

[Dl Dr] = find(A_D);

use = phase(Dl) == phase(Dr) & isIndexed(Dl) & isIndexed(Dr);
Dl = Dl(use); Dr = Dr(use);
phase = phase(Dl);

prop = []; zeros(size(Dl));
for p=1:numel(phaseMap)
  currentPhase = phase == phaseMap(p);
  if any(currentPhase)
    o_Dl = orientation(r(Dl(currentPhase)), CS{p}, SS);
    o_Dr = orientation(r(Dr(currentPhase)), CS{p}, SS);
    m  = o_Dl.\o_Dr; 
    misangle = angle(m);
    misangle(misangle > maxAngle) = 0.0;
    sum(misangle > maxAngle)
    prop(currentPhase,:) = misangle; %#ok<AGROW>
  end
end

hold on;
for i = 1:size(Dl)
  if Dl(i) == voronoiId
    % Center
    plot(xs(Dl(i)), ys(Dl(i)), marker, 'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', 'k');
    
    % Neighbors
    if prop(i) == 0.0
      plot(xs(Dr(i)), ys(Dr(i)), marker, 'MarkerEdgeColor', 'r', ...
            'MarkerSize', markerSize);
    else
      plot(xs(Dr(i)), ys(Dr(i)), marker, ...
            'MarkerSize', markerSize);
    end
    
    % Text id
%      text(xs(r(i)),ys(r(i)),int2str(r(i)));
     text(xs(Dr(i)),ys(Dr(i)),int2str(Dr(i)));
  end
end
end
