function q = discreteSample(q,npoints,varargin)
% draw a random sample
%

weights = get_option(varargin,'weights',ones(size(q)));

ind = discretesample(weights,npoints);

q = q.subSet(ind);

end