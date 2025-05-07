function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  MLS component"));
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
end

if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end

if SO3F.antipodal, disp('  antipodal: true'); end

if isa(SO3F.nodes,'SO3Grid')
  disp(['  nodes: ',char(SO3F.nodes)]);
else
  disp(['  nodes: ',num2str(length(SO3F.nodes)), ' orientations']);
end

disp(['  weight function: ' char(SO3F.w)]);
disp(['  polynomial degree: ' num2str(SO3F.degree)]);
disp(['  support radius of the weight function: ' xnum2str(SO3F.delta/degree) mtexdegchar]); 
disp(['  number of neighbors: ' num2str(SO3F.nn)])

if SO3F.all_degrees, disp('  all_degrees: true'); end
if SO3F.centered, disp('  centered: true'); end
if SO3F.tangent, disp('  tangent: true'); end

if length(SO3F.nodes)<1e4 || length(SO3F)>3
  w = calcVoronoiVolume(SO3F.nodes); w = w./sum(w);
else
  w = 1/length(SO3F.nodes);
end

if isscalar(SO3F)
  disp(['  weight: ' xnum2str(sum(SO3F.values.*w))]);
elseif length(SO3F)<4
  disp(['  weights: [' xnum2str(sum(SO3F.values.*w)),']']);
end

disp(' ')

end