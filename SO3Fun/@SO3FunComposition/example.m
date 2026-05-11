function f = example(varargin)
% Construct a SO3FunComposition by adding different SO3Funs.

CBF = SO3FunCBF.example; CBF.CS = crystalSymmetry.default;
RBF = SO3FunRBF.example; RBF.CS = crystalSymmetry.default;

f = SO3FunBingham.example + RBF + CBF +2;

end