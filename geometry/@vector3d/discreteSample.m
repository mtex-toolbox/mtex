function v = discreteSample(v,npoints,varargin)
% draw a random sample
%

weights = get_option(varargin,'weights',ones(size(v)));

ind = discretesample(weights,npoints);

v = v.subSet(ind);

end