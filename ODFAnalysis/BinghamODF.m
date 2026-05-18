function odf = BinghamODF(kappa,varargin)
% defines a Bingham distributed ODF
%
% Syntax
%   odf = BinghamODF(kappa,ori)
%   odf = BinghamODF(kappa,f)
%   odf = BinghamODF(kappa,A,CS,SS)
%   odf = BinghamODF(kappa,q,CS,SS)
%
% Input
%  kappa  - form parameter
%  ori    - principle @orientation
%  f      - @fiber
%  A      - orthogonal 4x4 matrix
%  q      - quaternion
%  CS, SS - crystal, specimen @symmetry
%
% Output
%  odf - @SO3FunBingham
%
% See also
% FourierODF uniformODF unimodalODF fibreODF


% get crystal and specimen symmetry
try
  CS = varargin{1}.CS;
  SS = varargin{1}.SS;
catch
  [CS,SS] = extractSym(varargin);
end

if numel(kappa) < 4
  kappa = [kappa(:);zeros(4-length(kappa),1)];
end
      
% get A
if nargin > 1 && isa(varargin{1},'double')

  A  = varargin{1};
  A = quaternion(A(:,1),A(:,2),A(:,3),A(:,4));
        
elseif nargin > 1 && isa(varargin{1},'vector3d') && isa(varargin{2},'vector3d')
        
  % if only one kappa was given extend in to the second one
  if isscalar(kappa), kappa(2) = kappa;end

  A = fibre2A(varargin{1},varargin{2});

elseif nargin > 1 && isa(varargin{1},'fibre')
  
  % if only one kappa was given extend in to the second one
  kappa(2) = kappa(1);

  A = fibre2A(varargin{1}.h,varargin{1}.r);  

elseif nargin > 1 && isa(varargin{1},'quaternion')
        
  A = varargin{1};
  
else
  
  A = quaternion.eye;
                        
end

% if only one orientation was given -> extend to matrix
if isscalar(A), A = quaternion.eye .* A; end
      
A = orientation(A,CS,SS);
          
%orthogonality check
assert(isappr(abs(det(squeeze(double(A)))),1),'Center must be orthogonal');
                  
odf = SO3FunBingham(kappa,A);

end

% -----------------------------------------
function A = fibre2A(h,r)

h = normalize(h);
r = normalize(r);

qr = quaternion(0,r.x,r.y,r.z);
qh = quaternion(0,h.x,h.y,h.z);

q1 = quaternion.id - qr*qh;
q2 = qr+qh;

if isnull(norm(h-r))
  v1 = orth(h);
  v2 = cross(h,v1);
  q3 = quaternion(0,v1.x,v1.y,v1.z);
  q4 = quaternion(0,v2.x,v2.y,v2.z);
else
  q3 = quaternion.id + qr*qh;
  q4 = qr-qh;
end

A = normalize([q1,q2,q3,q4]);
 
% reverse:
%h_0 = q_1^* q_2
%r_0 = q_2 q_1^*.

end
