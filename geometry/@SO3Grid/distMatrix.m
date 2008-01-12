function dMatrix = distMatrix(G1,G2,epsilon)
% generates sparse distance matrix
%% Input
%  G1,G2   - @SO3Grid
%  epsilon - maximum distance
%
%% Output
% dMatrix - double

if isempty(G2)
  if isempty(G1.dMatrix)
		G2 = G1;
  else
		dMatrix = G1.dMatrix;
    return
  end
end

Gl1 = GridLength(G1);
Gl2 = GridLength(G2);

if check_option(G2,'INDEXED')
	if (Gl1 < Gl2) || ~check_option(G1,'INDEXED')
		% tausche falls mglich und sinnvoll
		dMatrix = distMatrix(G2,G1,epsilon).';
		return
	end
elseif ~check_option(G1,'INDEXED')
  warning('not yet implemented') %#ok<WNTAG>
end

dMatrix = spalloc(GridLength(G1),GridLength(G2),50*GridLength(G1));

disp(' calculate distmatrix:')

% highly sophisticated algorithm
% uses construction of the grids

lz1 = cumsum([0,GridLength(G1.gamma)]);
   
if check_option(G2,'INDEXED')
	dz2 = GridLength(G2.gamma);
	lz2 = cumsum([0,dz2]);
	
  % f�r alle Rotationsachsen
  for iz2 = 1:GridLength(G2.alphabeta)
    
    if mod(iz2,50) == 0
      disp(['  ',int2str(100*iz2/GridLength(G2.alphabeta)),'% - ',...
        int2str(length(y)/dz2(iz2)),' none zero per row']);
    end
    
    % collect all rotational axes in G1 close to G2(iz2)
    Ind1 = find(G1.alphabeta,vector3d(G2.alphabeta,iz2),epsilon);
    Ind = [];
    for i = 1:length(Ind1)
      Ind = [Ind,(lz1(Ind1(i))+1):lz1(Ind1(i)+1)]; %#ok<AGROW>
    end
    
    % calculate rotational distance (due to crystal symmetry)
    if numel(Ind)>0
      d = dot_outer(G1.CS,G1.SS,G1.Grid(Ind),G2.Grid(lz2(iz2)+1:lz2(iz2+1)));
			[y,x] = find(d>cos(epsilon/2));
      dummy = sparse(Ind(y),lz2(iz2) + x.',d(y + (x-1)*length(Ind)),...
        GridLength(G1),GridLength(G2));
      
      dMatrix = dMatrix + dummy;
      %dMatrix(Ind(y) + Gl1*(lz2(iz2) + x.' -1)) = d(y + (x-1)*length(Ind));
    end

  end
else
  for iG2 = 1:length(G2.Grid)

    if mod(iG2,500) == 0
      disp(length(Ind));
    end
    
    q = G2.Grid(iG2);
    Ind1 = find(G1.alphabeta,q*zvector,epsilon);
    
    Ind = [];
    for i = 1:length(Ind1)
      Ind = [Ind,(lz1(Ind1(i))+1):lz1(Ind1(i)+1)]; %#ok<AGROW>
    end
    if numel(Ind)>0
      d = dist(G1.CS,G1.SS,q,G1.Grid(Ind));
      t = find(d<epsilon);
      Ind = Ind(t);
      
      dMatrix(Ind,iG2) = cos(d(t)/2);
    end
  end
end

% correction for values larger then 1
dMatrix = spfun(@(x)min(1,x),dMatrix);
