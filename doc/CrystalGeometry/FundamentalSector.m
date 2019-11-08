%% Fundamental Sector
%
%% TODO
% please expand this chapter

cs = crystalSymmetry('432')

plot(cs)
hold on
plot(cs.fundamentalSector,'color','Red')
hold off

%%

sR = cs.fundamentalSector

%%

sR.N

%%

v = Miller(2,3,1,cs)

%%
% We may check wether a direction is inside the fundamental region by the
% command <sphericalRegion.checkInside.html checkInside>

sR.checkInside(v)


%%

v.project2FundamentalRegion

%%

hold on
plot(v)
plot(v.project2FundamentalRegion,'MarkerFaceColor','Red')
hold off

