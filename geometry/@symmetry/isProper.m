function res = isProper(sym)
% does it contain only proper rotations

res = ~any(sym.rot.i(:));

end
