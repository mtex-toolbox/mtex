function [ori,value] = steepestDescent(odf,ori,varargin)
% find maximum with steepest descent

% specify parameters
maxIter = get_option(varargin,'maxIter',30);
res = get_option(varargin,'resolution',0.05*degree);
omega = 1.25.^(-30:1:10) * degree;
omega(omega<res) = [];
omega = [0,omega];

% compute gradient
G = odf.grad(varargin{:});

s = size(ori); 
ori = ori(:);

for k = 1:maxIter

  % gradient
  if check_option(varargin,'noNFFT')
    g = normalize(G.eval(ori,'noNFFT'));
  else
    g = normalize(G.eval(ori));
  end
  % prepare for linesearch
  line_ori = exp(g(:) * omega,repmat(ori(:),1,length(omega)),G.tangentSpace);
  
  % evaluate along lines
  if check_option(varargin,'noNFFT')
    line_v = odf.eval(line_ori,'noNFFT');
  else
    line_v = odf.eval(line_ori);
  end

  
  % take the maximum
  [value,id] = max(line_v,[],2);
  
  % update orientations
  ori = line_ori(sub2ind(size(line_ori),(1:length(ori)).',id));
  
  tol = get_option(varargin,'unique');
  if ~isempty(tol)
    [ori,id] = unique(ori,'tolerance',tol);
    value = value(id);
    s = size(ori);
  end

  if all(id == 1), break; end
  progress(k,maxIter)
  % fprintf(['Step size:',num2str(omega(max(id))/degree),'°\n'])
end

ori = reshape(ori,s);
value = reshape(value,s);

% [o2,v1,v2] = unique(ori)
% v = accumarray(v2,1)
%id = v>5;
%o2 = o2(id);
%v = v(id)


