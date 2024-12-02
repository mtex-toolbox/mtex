load triplepointSegmentsExampleData.mat

[s, sP, sf, sfF, sfD] = TriplepointSegments(F,V);

clf;
hold on;
for i=1:(size(s,1)-1)
    current_sP = sP(s(i):(s(i+1)-1));
    Vsection = V(current_sP,:);
    plot(Vsection(:,1),Vsection(:,2));
end

uiwait;

hold on;
i = 1:(size(s,1)-1);
plot([V(sP(s(i)),1)';V(sP(s(i+1)-1),1)'],[V(sP(s(i)),2)';V(sP(s(i+1)-1),2)']);
scatter([V(sP(s(i)),1)';V(sP(s(i+1)-1),1)'],[V(sP(s(i)),2)';V(sP(s(i+1)-1),2)']);
