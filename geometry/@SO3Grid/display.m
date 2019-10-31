function display(S3G)
% standard output

displayClass(S3G,inputname(1));

disp(['  symmetry: ',char(S3G.CS),' - ',char(S3G.SS)]);
disp(['  grid    : ',char(S3G)]);
