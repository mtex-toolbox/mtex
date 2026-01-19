function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  MLS component"));
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
end

if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end

if ~SO3F.isReal, disp('  isReal: false'); end
if SO3F.antipodal, disp('  antipodal: true'); end

if isa(SO3F.nodes,'SO3Grid')
  disp(['  nodes: ',char(SO3F.nodes)]);
else
  disp(['  nodes: ',num2str(length(SO3F.nodes)), ' orientations']);
end

% Weight of the SO3Fun (this is 1 in case of density)
warning off
if length(SO3F.nodes)<1e4 || length(SO3F)>3
  w = calcVoronoiVolume(SO3F.nodes); w = w./sum(w);
else
  w = 1/length(SO3F.nodes);
end

% display the 'weights'
if isscalar(SO3F)
  disp(['  weight: ' xnum2str(sum(SO3F.values.*w, 'all'))]);
elseif length(SO3F)<4
  vals = reshape(SO3F.values, numel(SO3F.nodes), numel(SO3F));
  disp(['  weights: [' xnum2str(sum(vals .* w)),']']);
end
warning on


% MLS Properites
prop = ['    weight function: ', char(SO3F.w) , ...
        '\n    polynomial degree: ', num2str(SO3F.degree), ...
        '\n    dimension of the ansatz space: ', num2str(SO3F.dim), ...
        '\n    support radius of the weight function: ', xnum2str(SO3F.delta/degree) mtexdegchar, ... 
        '\n    number of neighbors: ', num2str(SO3F.nn)];
if SO3F.centered, prop=[prop,'\n    centered: true']; end
if SO3F.tangent, prop=[prop,'\n    tangent: true']; end
if SO3F.subsample, prop=[prop,'\n    perform optimal subsampling: true']; end
if SO3F.detectOutliers
  prop = [prop, '\n    detect outlier: true']; 
  prop = [prop, '\n    OutlierDetectionRange: ', num2str(SO3F.outlierDetectionRange)]; 
end

disp(' ')
s = setAllAppdata(0,'data2beDisplayed',[prop,'\n']);
disp(['  <a href="matlab:fprintf(getappdata(0,''',s,'''))">show MLS-properties</a>'])
disp(' ')

end