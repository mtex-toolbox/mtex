function [A_Db,I_DG] = doSegmentation(I_FD,ebsd,gbc,varargin)
% segments voronoi cells into grains
%
% Input
%  I_FD - incidence matrix faces -> pixels
%  ebsd - @EBSD
%  gbc - @grainBoundaryCriterion
%
% Output
%  I_DG - incidence matrix pixels -> grains
%  A_Db - adjacency matrix of grain boundaries
%  A_Do - adjacency matrix inside grain connections
%

% get pairs of neighboring cells {D_l,D_r} in A_D
A_D = I_FD'*I_FD==1;
[Dl,Dr] = find(triu(A_D,1));

connect = gbc.eval(ebsd,Dl,Dr);

% adjacency of cells that have no common boundary
ind = connect>0;
A_Do = sparse(double(Dl(ind)),double(Dr(ind)),connect(ind),length(ebsd),length(ebsd));
if check_option(varargin,'mcl')
  
  param = get_option(varargin,'mcl');
  if isempty(param), param = 1.4; end
  if isscalar(param), param = [param,4]; end
  
  A_Do = mclComponents(A_Do,param(1),param(2));
  A_Db = sparse(double(Dl),double(Dr),true,length(ebsd),length(ebsd));
  A_Db(A_Do~=0) = false;
  
else
  
  A_Db = sparse(double(Dl(connect<1)),double(Dr(connect<1)),true,...
    length(ebsd),length(ebsd));
  
end
A_Do = A_Do | A_Do.';

% adjacency of cells that have a common boundary
A_Db = A_Db | A_Db.';

% compute I_DG connected components of A_Do
% I_DG - incidence matrix cells to grains
I_DG = sparse(1:length(ebsd),double(connectedComponents(A_Do)),1);

end