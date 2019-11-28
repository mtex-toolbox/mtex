function out = choose(cond,f1,f2)

out(cond) = f1(cond);
out(~cond) = f2(~cond);

end