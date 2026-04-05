function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  MLS component"));
else
  displayClass(SO3F,inputname(1),'moreInfo',char(SO3F.s,'compact'),varargin{:});
end

if length(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end

if ~SO3F.isReal, disp('  isReal: false'); end
if SO3F.antipodal, disp('  antipodal: true'); end

if isa(SO3F.nodes,'S2Grid')
  disp(['  nodes: ',char(SO3F.nodes)]);
else
  disp(['  nodes: ',num2str(length(SO3F.nodes))]);
end

% string for nn depends on whether nn or delta is set for mls
if (SO3F.delta == 0)
  knn_or_delta_string = 'knn-search';
else
  knn_or_delta_string = 'range-search';
end
if SO3F.monomials
  basis_string = 'monomials';
else
  basis_string = 'spherical harmonics';
end


% MLS properties
prop = ['    weight function: ', char(SO3F.w) , ...
        '\n    polynomial degree: ', num2str(SO3F.degree), ...
        '\n    oversampling factor: ', num2str(SO3F.oF), ...
        '\n    determine neighbors via: ', knn_or_delta_string, ...
        '\n    basis: ', basis_string];
if SO3F.centered, prop=[prop,'\n    centered: true']; end
if SO3F.tangent, prop = [prop,'\n    tangent: true']; end
if SO3F.regularize, prop = [prop,'\n    regularize: true']; end
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