function T = rotate_outer(T,R,varargin)
% rotate a tensor by a list of rotations
%
% Description
%
% $$T_{rst} = T_{ijk} R_{ri} R_{sj} R_{tk}$$
%
% Input
%  T - @tensor
%  R - @rotation or rotation matrix or a list of them
%
% Output
%  T - rotated @tensor
%

% the orientation has to act on the frame the tensor is expressed in -
% the symmetries need not agree, only the frames have to fit
if isa(R,'orientation') && nargin == 2
  R = fitFrame(R,T.CS.frame);

  % the rotated tensor takes the specimen frame, but not the specimen symmetry
  if R.SS.id == 1
    T.CS = R.SS;
  else
    ss = specimenSymmetry;
    ss.frame = R.SS.frame;
    T.CS = ss;
  end
end

if ~isnumeric(R), R = matrix(R); end
R = reshape(R,3,3,[]);

% the leading half of the indices is contracted from the left by a Kronecker
% power of R, the trailing half from the right, so no index has to move
p = floor(T.rank/2);
Kp = kronPower(ones(1,1,size(R,3)),R,p);
Kq = kronPower(Kp,R,T.rank-2*p);
M = pagemtimes(pagemtimes(Kp,reshape(T.M,3^p,3^(T.rank-p),1,[])),'none',Kq,'transpose');
T.M = reshape(M,[3*ones(1,T.rank) size(R,3) length(T)]);

end

function K = kronPower(K,R,p)
% append p Kronecker factors of R to K, page by page

N = size(R,3);
for k = 1:p
  m = size(K,1);
  K = reshape(reshape(K,[m 1 m 1 N]) .* reshape(R,[1 3 1 3 N]),[3*m 3*m N]);
end

end
