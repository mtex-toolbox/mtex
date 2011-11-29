function c = centroid( grains )



V = full(get(grains,'V'));
I_VG = get(grains,'I_VG');
[v,g] = find(I_VG);

cs = [0; find(diff(g));size(g,1)];
c = zeros(numel(grains),3);

for k=1:numel(grains)
  c(k,:) = mean(V(v(cs(k)+1:cs(k+1)),:),1);  
end

