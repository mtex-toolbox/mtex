function job = calcParent2Child(job, varargin)
      
% get neighbouring grain pairs
grainPairs = job.grains(job.csChild).neighbors;

p2c0 = orientation.KurdjumovSachs(job.csParent,job.csChild);
if ~isempty(job.p2c), p2c0 = job.p2c; end
p2c0 = getClass(varargin,'orientation',p2c0);

% compute an optimal parent to child orientation relationship
[job.p2c, job.fit] = calcParent2Child(job.grains(grainPairs).meanOrientation,p2c0);

end