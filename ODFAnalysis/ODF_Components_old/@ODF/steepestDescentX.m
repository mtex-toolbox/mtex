function [ori,value] = steepestDescentX(odf,ori,varargin)
% find maximum with steepest descent

maxIter = get_option(varargin,'maxIter',30);
res = get_option(varargin,'resolution',0.05*degree);
omega = 1.25.^(-30:1:10) * degree;
omega(omega<res) = [];
omega = [0,omega];

for k = 1:maxIter

  % gradient
  g = normalize(sum(odf.grad(ori,'left')));
  
  % prepare for linesearch
  line_ori = exp(repmat(ori(:),1,length(omega)),g(:) * omega,'left');
  
  % evaluate along lines
  line_v = sum(odf.eval(line_ori));
  
  % take the maximum
  [value,id] = max(line_v,[],2);
  
  %value
  
  % update orientions
  ori = line_ori(:,id);
  
  if all(id == 1), break; end
  fprintf('.')
end

% [o2,v1,v2] = unique(ori)
% v = accumarray(v2,1)
%id = v>5;
%o2 = o2(id);
%v = v(id)


