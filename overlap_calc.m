load ('overlap_demo.mat');
index = cell_to_index_map;

[wholecellnum, trial] = size(index);

AA1 = zeros(wholecellnum,1);
BB1 = zeros(wholecellnum,1);
CC1 = zeros(wholecellnum,1);

aa1 = 0;
bb1 = 0;
cc1 = 0;

for n=1:wholecellnum
    if (index(n,1) == 0) && (index(n,2) ~= 0)
        AA1(n,1) = index(n,2);
        aa1 = aa1+1;
    else continue
    end
end

for n=1:wholecellnum
    if (index(n,3) == 0) && (index(n,4) ~= 0)
        BB1(n,1) = index(n,4);
        bb1 = bb1+1;
    else continue
    end
end

for n=1:wholecellnum
    if (index(n,5) == 0) && (index(n,6) ~= 0)
        CC1(n,1) = index(n,6);
        cc1 = cc1+1;
    else continue
    end
end

AA1_bin = AA1>0;
BB1_bin = BB1>0;
CC1_bin = CC1>0;

ab1 = 0;
bc1 = 0;
ca1 = 0;

for i=1:wholecellnum
    if (AA1_bin(i,1) ~= 0) && (BB1_bin(i,1) ~= 0)
        ab1 = ab1+1;
    else continue;
    end
end

for i=1:wholecellnum
    if (BB1_bin(i,1) ~= 0) && (CC1_bin(i,1) ~= 0)
        bc1 = bc1+1;
    else continue;
    end
end

for i=1:wholecellnum
    if (CC1_bin(i,1) ~= 0) && (AA1_bin(i,1) ~= 0)
        ca1 = ca1+1;
    else continue;
    end
end

ab2 = 0;
bc2 = 0;
ca2 = 0;

ab2 = sum(AA1_bin) + sum(BB1_bin) - ab1;
bc2 = sum(BB1_bin) + sum(CC1_bin) - bc1;
ca2 = sum(CC1_bin) + sum(AA1_bin) - ca1;

neuron_union_number = [ab2 bc2 ca2];

neuron_percent = [ab1/ab2*100 bc1/bc2*100 ca1/ca2*100];

neuron_percent_6_72_78 = [bc1/bc2*100 ab1/ab2*100 ca1/ca2*100]
