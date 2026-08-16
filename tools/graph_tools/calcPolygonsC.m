function [poly,inclusionId] = calcPolygonsC(I_FG,F,V,N)
%
% Input
%  I_FG -
%  F -
%
% Output
%  poly        - cell list of indices to V
%  inclusionId - number of trailing vertices in poly{k} belonging to
%                inclusion (hole) loops, i.e. numel(poly{k}) minus the
%                length of the main (largest area) loop. Known for free
%                here since every grain's cycles are traced individually
%                below; see EBSDAnalysis/@grain2d/grain2d.m.

% compute cycles - EulerCyclesC reads I_FG with mxGetPr and F with
% mxGetDoubles, so both have to be double (a sparse logical I_FG or single
% precision F would crash the mex)
[g, c, cP] = EulerCyclesC(double(I_FG),double(F),size(V,1));
% g - each entry represents one grain, except for the last one. 
%     For each grain, the first index of the cycles belonging to this grain is stored.
%     The last element is the total number of cycles.
% c - Each entry represents one cycle, except for the last one.
%     For each cycle, the first index of cyclePoints belonging to this cycle is stored.
%     The last element is the total number of cyclePoints.
% cP - cyclePoints: Array of point indices (V).

% compute area of each cycle
if isnumeric(V)
  area = polySgnArea(V(cP,1),V(cP,2),c);
else
  area = polySgnArea3(V(cP,:).xyz,N.xyz,c);
end

% convert to cell array
poly = cell(size(I_FG,2),1);
inclusionId = zeros(size(I_FG,2),1);
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
      if xor(area(g(ig)-1+ic) < 0, I(1)==ic)
        ind = cStart:cEnd;
      else
        ind = cEnd:-1:cStart;
      end

      % every cycle should end with the very first point of the grain
      if I(1)==ic
        localPoints{ic} = cP(ind).';
      else
        localPoints{ic} = cP([ind ind0]).';
      end
    end
    poly{ig} = [localPoints{I}];
    inclusionId(ig) = numel(poly{ig}) - numel(localPoints{I(1)});
  end
end