function display(S2F, varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  MLS component"));
else
  str = [char(S2F.CS,'compact') ' ' char(8594) ' ' char(S2F.SS,'compact')];
  displayClass(S2F,inputname(1),[],'moreInfo',str,varargin{:});
end

if length(S2F) > 1, disp(['  size: ' size2str(S2F)]); end

if S2F.antipodal, disp('  antipodal: true'); end

if isa(S2F.nodes,'S2Grid')
  disp(['  nodes: ',char(S2F.nodes)]);
else
  disp(['  nodes: ',num2str(length(S2F.nodes)), ' orientations']);
end

disp(['  weight function: ' char(S2F.w)]);
disp(['  polynomial degree: ' num2str(S2F.degree)]);
disp(['  dimension of the ansatz space: ' num2str(S2F.dim)]);
disp(['  support radius of the weight function: ' xnum2str(S2F.delta/degree) mtexdegchar]); 
disp(['  number of neighbors: ' num2str(S2F.nn)])
disp(['  oversampling factor: ' num2str(S2F.nn / S2F.dim)]);

if S2F.centered, disp('  centered: true'); end
if S2F.tangent, disp('  tangent: true'); end
if S2F.subsample, disp('  perform optimal subsampling: true'); end

if length(S2F.nodes)<1e4 || length(S2F)>3
  w = calcVoronoiArea(S2F.nodes); w = w./sum(w);
else
  w = 1/length(S2F.nodes);
end

if isscalar(S2F)
  disp(['  weight: ' xnum2str(sum(S2F.values.*w))]);
elseif length(S2F)<4
  disp(['  weights: [' xnum2str(sum(S2F.values.*w)),']']);
end

disp(' ')

end