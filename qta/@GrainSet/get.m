function varargout = get(grains,vname,varargin)
% return property of a GrainSet
%
% Input
% grains - @GrainSet
%
% Syntax
%   % returns the mean orientation of grains
%   o = get(grains,'meanOrientation')
%   o = get(grains,'orientations')    % returns individual orientations of the
%                                      EBSD data from which grains were
%                                      constructed.
%   m = get(grains,'mis2mean')        % returns the misorientation of the
%                                      EBSD data to the mean orientation of
%                                      each grain.
%   p = get(grains,'phase')           % returns the phase index of grains
%   A = get(grains,'A_D')             % returns the adjacency matrix of neighbored
%                                      EBSD measurments.
%   I = get(grains,'I_DG')            % returns the incidence matrix ebsd measurement
%                                      incident to grain.
%   s = get(grains,'CS')              % returns the first indexed crystal symmetry
%                                      of the grains.
%   p = get(grains,'mad')             % returns the MAD property of the EBSD data, if MAD is a
%                                      property of EBSD data from which the
%                                      grains were constructed.
%
% Input
%  grains - @GrainSet
%
% Output
%  o,m - @orientation
%  s - @symmetry
%  A,I - sparse matrix
%  p - double
%
% See also
% EBSD/set

properties = get_obj_fields(grains.prop);
options    = get_obj_fields(grains.opt);
if nargin == 1
  vnames = [properties;options;{'data';'quaternion';'orientations';'Euler';'mineral';'minerals'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end


switch lower(vname)
  
  case 'phase'
    
    varargout{1} = grains.phaseMap(grains.gphase);
    
  case {'mean','meanorientation','orientation'}
    
    % check only a single phase is involved
    if numel(unique(grains.phase)) > 1
      
      error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
        'See ' doclink('xx','xx')  ...
        ' for how to restrict EBSD data to a single phase.']);
      
    elseif numel(grains.phase) == 0
      
      varargout{1} = [];
      
    else
      
      varargout{1} = orientation(grains.meanRotation,grains.CS{grains.phase(1)});
      
    end
    
  case {'rotation'}
    
    varargout{1} = grains.meanRotation;
    
    %   case {'mis2mean'}
    %
    %     mapping = any(grains.I_DG,1);
    %     [g,d] = find(grains.I_DG(:,mapping)');
    %
    %     o = get(grains,'rotations');
    %     m = grains.meanRotation(g);
    %     varargout{1} = orientation(inv(o) .* m,get(grains,'CS'),get(grains,'CS'));
    %    
    
  otherwise
    
    try
      varargout{1} = get@EBSD(grains,vname,varargin{:});
      return
    catch
      error(['Unknown Property "' vname '" in class GrainSet']);
    end
    
end
