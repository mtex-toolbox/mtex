function display(S2F, varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp(strong("  MLS component"));
else
  displayClass(S2F,inputname(1),'moreInfo',char(S2F.s,'compact'),varargin{:});
end

if length(S2F) > 1, disp(['  size: ' size2str(S2F)]); end

if ~S2F.isReal, disp('  isReal: false'); end
if S2F.antipodal, disp('  antipodal: true'); end

if isa(S2F.nodes,'S2Grid')
  disp(['  nodes: ',char(S2F.nodes)]);
else
  disp(['  nodes: ',num2str(length(S2F.nodes))]);
end

% string for nn depends on whether nn or delta is set for mls
if (S2F.delta == 0)
  knn_or_delta_string = 'knn-search';
else
  knn_or_delta_string = 'range-search';
end
if S2F.monomials
  basis_string = 'monomials';
else
  basis_string = 'spherical harmonics';
end


% MLS properties
prop = ['    weight function: ', char(S2F.w) , ...
        '\n    polynomial degree: ', num2str(S2F.degree), ...
        '\n    oversampling factor: ', num2str(S2F.oF), ...
        '\n    determine neighbors via: ', knn_or_delta_string, ...
        '\n    basis: ', basis_string];
if S2F.centered, prop=[prop,'\n    centered: true']; end
if S2F.tangent, prop = [prop,'\n    tangent: true']; end
if S2F.regularize, prop = [prop,'\n    regularize: true']; end
if S2F.subsample, prop=[prop,'\n    perform optimal subsampling: true']; end
if S2F.detectOutliers
  prop = [prop, '\n    detect outlier: true']; 
  prop = [prop, '\n    OutlierDetectionRange: ', num2str(S2F.outlierDetectionRange)]; 
end

disp(' ')
s = setAllAppdata(0,'data2beDisplayed',[prop,'\n']);
disp(['  <a href="matlab:fprintf(getappdata(0,''',s,'''))">show MLS-properties</a>'])
disp(' ')


end