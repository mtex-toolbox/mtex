function f = eval(SO3F,rot,varargin)
% pointwise evaluation of SO3F at rotations rot
%
% sum_i \sum_j \sum_k  weights * psi(g*s_j h_i . s_k r_i)

% TODO: Use weights

h = symmetrise(SO3F.h.normalize,'unqiue');

% g x SS x CS x h
gh = reshape((SO3F.SS.properGroup * rot).' * h, length(rot),[]);

f = mean(SO3F.psi.eval(dot(gh,normalize(SO3F.r),'noSymmetry')),2);

f = reshape(f,size(rot));