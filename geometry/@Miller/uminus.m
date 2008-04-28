function mm = uminus(m)
% implement -Miller

mm = Miller(-[m.h],-[m.k],-[m.l],m(1).CS);
