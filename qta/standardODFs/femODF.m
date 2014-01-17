function odf = femODF(C,CS,SS)
% defines an ODF by finite elements
%
% Syntax
%   odf = femODF(C,CS,SS)
%
% Input
%  center - @DSO3
%  weights -
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF fibreODF unimodalODF
                 
if nargin == 0, return;end
      
% get center
if nargin > 0 && isa(varargin{1},'quaternion')
  
  odf.center = varargin{1};
  
  if isa(odf.center,'orientation')
    odf.CS = get(odf.center,'CS');
    odf.SS = get(odf.center,'SS');
  else
    odf.center = orientation(odf.center,odf.CS,odf.SS);
  end
else
  odf.center = orientation(idquaternion,odf.CS,odf.SS);
end

% get weights
odf.weights = get_option(varargin,'weights',ones(size(odf.center)));


assert(numel(odf.weights) == length(odf.center),...
  'Number of orientations and weights must be equal!');
            
end
    
