function images=Select_images(tn,n,sn);

for i=1:tn
    x(i)=i;
end
num=nchoosek(tn,n);    %%% number of combination
com=combntns(x,n);      %%% all combinations
p = randperm(num,sn);      %%% select k elements from all combinations
for i=1:sn
    for j=1:n
        images(i,j)=com(p(i),j);
    end
end
