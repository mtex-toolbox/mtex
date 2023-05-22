function f = eval(SO3F,rot,varargin)
% pointwise evaluation of SO3F at rotations rot
%
% sum_i \sum_j \sum_k  weights * psi(g*s_j h_i . s_k r_i)

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3F,rot)
% end

s = size(rot);
rot = rot(:);

h = symmetrise(SO3F.h.normalize,'unqiue');

% rot x SS x CS x h
gh = reshape((SO3F.SS.properGroup * rot).' * h, length(rot),[],length(SO3F.h));

f = mean(SO3F.psi.eval(dot(gh,reshape(normalize(SO3F.r),1,1,[]),'noSymmetry')),2);

f = reshape(reshape(f,length(rot),[]) * SO3F.weights,s);

if isalmostreal(f)
  f = real(f);
end
