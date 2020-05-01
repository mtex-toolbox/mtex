clear all
SO3F=SO3FunHarmonic(rand(deg2dim(128),1));
rot=rotation.rand;

[~,time3]=eval2v3(SO3F,rot);

[~,time2]=eval2(SO3F,rot);

