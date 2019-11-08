function touch(fname)

fname = which(fname);
unix(['touch ' fname]);