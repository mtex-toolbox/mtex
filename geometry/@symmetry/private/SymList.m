function l = SymList

l = struct('Schoen',{},'Inter',{},'Laue',{},'Rot',{},'System',{},'Inversion',{});

% Schoen, Inter, Laue , Rot ,a, b, Typ, Syms
l = addSym(l,'C1' ,'1'    ,'-1'   ,'1'  ,'triclinic'    , 1);
l = addSym(l,'Ci' ,'-1'   ,'-1'   ,'1'  ,'triclinic'    ,-1);
l = addSym(l,'C2' ,'2'    ,'2/m'  ,'2'  ,'monoclinic'   ,1);
l = addSym(l,'Cs' ,'m'    ,'2/m'  ,'2'  ,'monoclinic'   ,-1);
l = addSym(l,'C2h','2/m'  ,'2/m'  ,'2'  ,'monoclinic'   ,[-1; 1]);
l = addSym(l,'D2' ,'222'  ,'mmm'  ,'222','orthorhombic' ,[1 1]);
l = addSym(l,'D2' ,'22'   ,'mmm'  ,'222','orthorhombic' ,[1 1]);
l = addSym(l,'C2v','2mm'  ,'mmm'  ,'222','orthorhombic' ,[-1 1]);
l = addSym(l,'C2v','mm2'  ,'mmm'  ,'222','orthorhombic' ,[-1 1]);
l = addSym(l,'D2h','mmm'  ,'mmm'  ,'222','orthorhombic' ,[[1 1];[-1 -1]]);
l = addSym(l,'D2h','2/m2/m2/m','mmm','222','orthorhombic',[[1 1],[-1 -1]]);
l = addSym(l,'C3' ,'3'    ,'-3'   ,'3'  ,'trigonal'     ,1);
l = addSym(l,'C3i','-3'   ,'-3'   ,'3'  ,'trigonal'     ,-1);
l = addSym(l,'D3' ,'32'   ,'-3m'  ,'32' ,'trigonal'     ,[1 1]);
l = addSym(l,'C3v','3m'   ,'-3m'  ,'32' ,'trigonal'     ,[-1 1]);
l = addSym(l,'D3d','-3m'  ,'-3m'  ,'32' ,'trigonal'     ,[[1 1];[-1 -1]]);
l = addSym(l,'D3d','-32/m','-3m'  ,'32' ,'trigonal'     ,[[1 1];[-1 -1]]);
l = addSym(l,'C4' ,'4'    ,'4/m'  ,'4'  ,'tetragonal'   ,1);
l = addSym(l,'S4' ,'-4'   ,'4/m'  ,'4'  ,'tetragonal'   ,-1);
l = addSym(l,'C4h','4/m'  ,'4/m'  ,'4'  ,'tetragonal'   ,[1;-1]);
l = addSym(l,'D4' ,'422'  ,'4/mmm','422','tetragonal'   ,[1 1]);
l = addSym(l,'D4' ,'42'   ,'4/mmm','422','tetragonal'   ,[1 1]);
l = addSym(l,'C4v','4mm'  ,'4/mmm','422','tetragonal'   ,[-1 1]);
l = addSym(l,'D2d','-42m' ,'4/mmm','422','tetragonal'   ,[1 -1]);
l = addSym(l,'D4h','4/mmm','4/mmm','422','tetragonal'   ,[[1 1];[-1 -1]]);
l = addSym(l,'D4h','4/m2/m2/m','4/mmm','422','tetragonal',[[1 1];[-1 -1]]);
l = addSym(l,'C6' ,'6'    ,'6/m'  ,'6'  ,'hexagonal'    ,1);
l = addSym(l,'C3h','-6'   ,'6/m'  ,'6'  ,'hexagonal'    ,-1);
l = addSym(l,'C6h','6/m'  ,'6/m'  ,'6'  ,'hexagonal'    ,[1;-1]);
l = addSym(l,'D6' ,'622'  ,'6/mmm','622','hexagonal'    ,[1 1]);
l = addSym(l,'D6' ,'62'   ,'6/mmm','622','hexagonal'    ,[1 1]);
l = addSym(l,'C6v','6mm'  ,'6/mmm','622','hexagonal'    ,[-1 1]);
l = addSym(l,'D3h','-62m' ,'6/mmm','622','hexagonal'    ,[1 -1]);
l = addSym(l,'D3h','-6m2' ,'6/mmm','622','hexagonal'    ,[1 -1]);
l = addSym(l,'D6h','6/m2/m2/m','6/mmm','622','hexagonal',[[1 1];[-1 -1]]);
l = addSym(l,'D6h','6/mmm','6/mmm','622','hexagonal'    ,[[1 1];[-1 -1]]);
l = addSym(l,'T'  ,'23'    ,'m-3' ,'23' ,'cubic'        ,[1 1 1]);
l = addSym(l,'Th' ,'m3'    ,'m-3' ,'23' ,'cubic'        ,[[1 1 1];[-1 -1 -1]]);
l = addSym(l,'Th' ,'m-3'   ,'m-3' ,'23' ,'cubic'        ,[[1 1 1];[-1 -1 -1]]);
l = addSym(l,'Th' ,'2/m-3' ,'m-3' ,'23' ,'cubic'        ,[[1 1 1];[-1 -1 -1]]);
l = addSym(l,'O'  ,'432'   ,'m-3m','432','cubic'        ,[1 1 1]);
l = addSym(l,'O'  ,'43'    ,'m-3m','432','cubic'        ,[1 1 1]);
l = addSym(l,'Td' ,'-43m'  ,'m-3m','432','cubic'        ,[1 -1 -1]);
l = addSym(l,'Oh' ,'m3m'   ,'m-3m','432','cubic'        ,[[1 1 1];[-1 -1 -1]]);
l = addSym(l,'Oh' ,'m-3m'  ,'m-3m','432','cubic'        ,[[1 1 1];[-1 -1 -1]]);
l = addSym(l,'Oh' ,'4/m-32/m','m-3m','432','cubic'      ,[[1 1 1];[-1 -1 -1]]);

function nl = addSym(l,Schoen,Inter,Laue,Rot,Syst,Inv)

s = struct('Schoen',Schoen,'Inter',Inter,'Laue',Laue,'Rot',Rot,'System',Syst,'Inversion',Inv);
nl = [l,s];
