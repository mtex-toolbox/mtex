function q = project2FundamentalRegion(q,CS1,CS2,varargin)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS)       % to FR
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


% get the reference quaternion
if nargin == 3 && ~isa(CS2,'symmetry') && isa(CS2,'quaternion')
  
  q_ref = CS2;
  
elseif nargin == 4 && isa(varargin{1},'quaternion')
  
  q_ref = varargin{1};
  varargin{1} = [];
  
else
  
  q_ref = [];
  
end

% distingish different cases
if nargin >= 3 && isa(CS2,'symmetry') && numSym(CS2)>1
  if isempty(q_ref) || abs(q_ref.a)==1
    q = project2FRCS2(q,CS1,CS2,varargin{:});
  else
    q = project2FRCS2_ref(q,CS1,CS2,q_ref);
  end
else
  q = project2FR_ref(q,CS1,q_ref);
end