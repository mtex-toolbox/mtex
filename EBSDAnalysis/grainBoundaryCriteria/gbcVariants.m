classdef gbcVariants < grainBoundaryCriterion
% gbcVariants  grain boundary criterion from variant ids
%
% Two neighbouring measurements belong to the same grain iff they carry the
% same variant id. Used for variant-based (parent/child) grain computation.
%
% Syntax
%
%   criterion = gbcVariants('variants',ids);
%   out = criterion.eval(ebsd,i,j);
%
% Output
%   out = 1   same variant id (same grain)
%   out = 0   grain boundary
%
% ids is a per-pixel array (one row per measurement); several columns are
% allowed and all must match.

properties
  ids = []
end

methods

  function obj = gbcVariants(varargin)
    if nargin >= 1 && isnumeric(varargin{1})
      obj.ids = varargin{1};
    else
      obj.ids = get_option(varargin,{'variants','ids'},obj.ids);
    end
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)

    ids = obj.ids;

    ok = numel(ids) > 0 && size(ids,1) == length(ebsd) && ...
      all(floor(ids(:)) == ids(:));
    assert(ok, ...
      'Provide a list of valid variant IDs to compute grains from variant Ids');

    % all id columns must agree
    out = double(all(ids(i,:) == ids(j,:),2));
    out = reshape(out,size(i));
  end

end

end