function f = example(varargin)
% Construct a SO3FunComposition by adding different SO3Funs.

CBF = SO3FunCBF.example; CBF.CS = crystalFrame;
RBF = SO3FunRBF.example; RBF.CS = crystalFrame;

f = SO3FunBingham.example + RBF + CBF +2;

end