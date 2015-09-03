function q = project2FundamentalRegion(q,CS1,CS2,varargin)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS)       % to FR around idquaternion
%   project2FundamentalRegion(q,CS,q_ref) % to FR around reference rotation
%   project2FundamentalRegion(q,CS1,CS2,q_ref)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%  q_ref    - reference @quaternion single or size(q) == size(q_ref)
%
% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%


% distingish different cases
if nargin == 2
  
  q = project2FR(q,CS1,idquaternion);

else
  
  if isa(CS2,'symmetry')
  
    if nargin > 3 && isa(varargin{1},'quaternion')
  
      q = project2FRCS2_ref(q,CS1,CS2,quaternion(varargin{1}));
      
    else
      
      q = project2FRCS2(q,CS1,CS2,varargin{:});
  
    end
  else
    
    q = project2FR_ref(q,CS1,CS2);
    
  end
  
end
