function o = orientation(varargin)
% defines an orientation

% empty quaternion;
rot = rotation;

%% empty constructor
if nargin == 0
  
  o.CS = symmetry;
  o.SS = symmetry;
    
%% copy constructor
elseif isa(varargin{1},'orientation')
        
  o = varargin{1};
  return;

%% determine crystal and specimen symmetry
else
  
  args  = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));

  if length(args) >= 1
    o.CS = varargin{args(1)};
  else
    o.CS = symmetry;
  end

  if length(args) >= 2
    o.SS = varargin{args(2)};
  else
    o.SS = symmetry;
  end
  
  if check_option(varargin,'Miller')
    
    args = find_option(varargin,'Miller');
    
    rot = rotation(Miller2quat(varargin{args+1},varargin{args+2},o.CS));
  
  else
    
    rot = rotation(varargin{:});
    
  end
  
end

superiorto('quaternion','rotation','symmetry');
o = class(o,'orientation',rot);
