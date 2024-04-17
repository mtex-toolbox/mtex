function odf = BinghamODF(varargin)
% defines a Bingham distributed ODF
%
% Description
% BinghamODF defines a Bingham distributed ODF with A and Lambda.
%
% Syntax
%   odf = BinghamODF(kappa,A,CS,SS)
%   odf = BinghamODF(kappa,q,CS,SS)
%   odf = BinghamODF(kappa,h,r,CS,SS)
%
% Input
%  kappa  - form parameter
%  A      - orthogonal 4x4 matrix
%  q      - quaternion
%  h,r    - fibre
%  CS, SS - crystal, specimen @symmetry
%
% Output
%  odf - @SO3Fun
%
% See also
% FourierODF uniformODF unimodalODF fibreODF


% get crystal and specimen symmetry
try
  CS = varargin{2}.CS;
  SS = varargin{2}.SS;
catch
  [CS,SS] = extractSym(varargin);
end

% get kappa
kappa = argin_check(varargin{1},'double');

if numel(kappa) < 4
  kappa = [kappa(:);zeros(4-length(kappa),1)];
end
      
% get A
if nargin > 1 && isa(varargin{2},'double')
        
  A = quaternion(varargin{2});
        
elseif nargin > 1 && isa(varargin{2},'vector3d') && isa(varargin{3},'vector3d')
        
  % if only one kappa was given extend in to the second one
  if isscalar(varargin{1}), kappa(2) = varargin{1};end

  A = fibre2A(varargin{2},varargin{3});

elseif nargin > 1 && isa(varargin{2},'fibre')
  
  % if only one kappa was given extend in to the second one
  if isscalar(varargin{1}), kappa(2) = varargin{1};end

  A = fibre2A(varargin{2}.h,varargin{2}.r);  

elseif nargin > 1 && isa(varargin{2},'quaternion')
        
  A = varargin{2};
  
else
  
  A = quaternion(eye(4));
                        
end
      
% if only one orientation was given -> extend to matrix
if isscalar(A), A = quaternion(eye(4)) * A; end
      
A = orientation(A,CS,SS);
      
    
%orthogonality check
assert(isappr(abs(det(squeeze(double(A)))),1),'Center must be orthogonal');
                  
odf = SO3FunBingham(kappa,A);

end

% -----------------------------------------
function A = fibre2A(h,r)

h = normalize(h);
r = normalize(r);

qr = quaternion(0,r);
qh = quaternion(0,h);

q1 = quaternion.id - qr*qh;
q2 = qr+qh;

if isnull(norm(h-r))
  v1 = orth(h);
  v2 = cross(h,v1);
  q3 = quaternion(0,v1);
  q4 = quaternion(0,v2);
else
  q3 = quaternion.id + qr*qh;
  q4 = qr-qh;
end

A = normalize([q1,q2,q3,q4]);
 
% reverse:
%h_0 = q_1^* q_2
%r_0 = q_2 q_1^*.

end
