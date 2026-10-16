function displayBody(F,name,header,varargin)
% standard output of an MLS function, below the class specific header

if check_option(varargin,'skipHeader')
  disp(strong("  MLS component"));
else
  displayClass(F,name,'moreInfo',header,varargin{:});
end

if length(F) > 1, disp(['  size: ' size2str(F)]); end
if ~F.isReal, disp('  isReal: false'); end
if F.antipodal, disp('  antipodal: true'); end

if isa(F.nodes,'S2Grid') || isa(F.nodes,'SO3Grid')
  disp(['  nodes: ',char(F.nodes)]);
else
  disp(['  nodes: ',num2str(length(F.nodes))]);
end

% the neighborhoods are either fixed in size or in radius
if F.delta == 0
  search = 'knn-search';
else
  search = 'range-search';
end

prop = ['    polynomial degree: ', num2str(F.degree), ...
  '\n    basis: ', F.basisName, ...
  '\n    oversampling factor: ', num2str(F.oF), ...
  '\n    determine neighbors via: ', search, ...
  '\n    weight function: ', char(F.w)];

if F.use_vor_weights, prop = [prop,'\n    Voronoi-weights: true']; end
if F.use_smooth_delta, prop = [prop,'\n    smoothed delta(x): true']; end
if F.centered, prop = [prop,'\n    centered: true']; end
if F.tangent, prop = [prop,'\n    tangent: true']; end
if F.regularize, prop = [prop,'\n    regularize: true']; end
if F.subsample, prop = [prop,'\n    perform optimal subsampling: true']; end
if F.detectOutliers
  prop = [prop,'\n    detect outlier: true', ...
    '\n    OutlierDetectionRange: ',num2str(F.outlierDetectionRange)];
end

disp(' ')
s = setAllAppdata(0,'data2beDisplayed',[prop,'\n']);
disp(['  <a href="matlab:fprintf(getappdata(0,''',s,'''))">show MLS-properties</a>'])
disp(' ')

end
