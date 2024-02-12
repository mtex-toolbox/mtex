function poly = calcPolygonsC(I_FG,F,V)

% compute cycles
[grains, cycles, cyclePoints] = EulerCyclesC(I_FG,F,V);
c = [cycles(:,1); length(cyclePoints)+1];
g = [grains(:,1); grains(end,1) + grains(end,2)];

% add the final point to each cycle - we should do this already in the C code
% -------------------------------------------------------------------------
cP = zeros(c(end)+length(c)-2,1);
nc = diff(c);
i = 1;
for ic = 1:length(cycles)
  ind = [c(ic):c(ic+1)-1,c(ic)];
  cP(i:i+nc(ic)) = cyclePoints(ind);  
  i = i + nc(ic) + 1;
end
c = c + (0:length(c)-1).';
% -------------------------------------------------------------------------

% compute area of each cycle
area = polySgnArea(V(cP,1),V(cP,2),c);

% convert to cell array 
poly = cell(size(I_FG,2),1);
for ig = 1:size(I_FG,2) % for all grains
  
  
  if g(ig+1)-g(ig) == 1 % only one cycle
    cStart = c(g(ig));
    cEnd = c(g(ig)+1)-1;
    if area(g(ig))>0
      poly{ig} = cP(cStart:cEnd).';
    else
      poly{ig} = cP(cEnd:-1:cStart).';
    end    
  else % if there are multiple cycles for one grain we have to sort them

    localPoints = cell(1,g(ig+1)-g(ig));

    % sort by area
    [~,I] = sort(-abs(area(g(ig):g(ig+1)-1)));

    ind0 = c(g(ig)-1+I(1));

    % for all cycles
    for ic = 1:g(ig+1)-g(ig) 
      
      cStart = c(g(ig)-1+ic);
      cEnd = c(g(ig)+ic)-1;

      % first cycle should have positive area - all other cycles negative area
      if xor(area(g(ig)-1+ic) < 0,I(ic)==1)
        ind = cStart:cEnd;
      else
        ind = cEnd:-1:cStart;
      end

      % every cycle should end with the very first node of the grain
      if I(ic)==1
        localPoints{ic} = cP(ind).';
      else
        localPoints{ic} = cP([ind ind0]).';
      end
    end
    poly{ig} = [localPoints{I}];
  end
end
