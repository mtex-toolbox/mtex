function data = remove_outlier(data)
% remove outlier

dd = sort(reshape(data,[],1));
mmin = dd(1+fix(length(dd)*0.05));
mmax = dd(1+fix(length(dd)*0.95));

d = std(dd);

for y = 1:size(data,1)
    for x = 1:size(data,2)
        
        regionx = max(min(x+(-1:1),size(data,2)),1);
        regiony = max(min(y+(-1:1),size(data,1)),1);
        if ((data(y,x) > mmax) || (data(y,x) < mmin))...
                && abs(mean(mean(data(regiony,regionx))) - data(y,x)) > 2*d
            data(y,x) = mean(mean(data(regiony,regionx))) - ...
                sign(mean(mean(data(regiony,regionx))) - data(y,x))*2*d;
        end
    end
end

