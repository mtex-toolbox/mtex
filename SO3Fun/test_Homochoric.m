
ori = orientation.rand(1000)

odf = unimodalODF(ori)

S3G = homochoricSO3Grid(odf.CS)

values = odf.eval(S3G);

odfhom = SO3FunHomochoric(S3G,values)

%%

ori2 = orientation.rand(1000000,1);
mean(abs(odfhom.eval(ori2)-odf.eval(ori2)))

tic
odfhom.eval(ori2);
toc

tic
odf.eval(ori2);
toc


%%

plot(odfhom)


%%
% You should see at the Euler angles (180,x,0) that there is a problem 
