clear;clc;
img_path = '..\Multi-criterion Sampling Matting Algorithm via Gaussian  Process\data\input\';
trimap_path = '..\Multi-criterion Sampling Matting Algorithm via Gaussian  Process\data\trimap\';
result_path = '..\Multi-criterion Sampling Matting Algorithm via Gaussian  Process\results\';
img_dir=dir([img_path,'*.png']);
trimap_dir=dir([trimap_path,'*.png']);
for j=13
    img_url=[img_path,img_dir(j).name];
    trimap_url=[trimap_path,trimap_dir(j).name];
    img = imread(img_url);
    trimap = imread(trimap_url);
    
    [F_ind,B_ind,U_ind,F_rgb,B_rgb,U_rgb,F_s,B_s,U_s,F_mindist,B_mindist] = GetMattingInfo(img,trimap);
    FB_U = bwdist(trimap ==128);
    F_U = FB_U(F_ind);
    B_U = FB_U(B_ind);
    FB_pairs=zeros(length(U_ind),2);
    CB = CheckerboardGenerator(size(trimap));
    U_CB = CB(U_ind);
    parfor n = 1:length(U_ind)
        if ~U_CB(n)
            FB_pairs(n,:) = [0,0];
            continue;
        end
        X = myfunction(n,U_rgb,F_rgb,B_rgb,U_s,F_s,B_s,F_U,B_U,50,10);
        fitness =  ColorCostFunc(X,F_rgb,B_rgb,U_rgb(n,:));
        h_pp = find(min(fitness)+1 > fitness);
        fitness1 = FuzzyCostFunc(X(h_pp,:),F_rgb,B_rgb,U_rgb(n,:),F_s,B_s,U_s(n,:),F_mindist(n,:),B_mindist(n,:));
        [~,o_pp]= sort(fitness1,'ascend');
        FB_pairs(n,:) = X(h_pp(o_pp(1)),:);
    end
    map_global_U_ind =zeros(size(trimap));
    map_global_U_ind(U_ind) = 1:length(U_ind);
    img_size = size(trimap);
    neighbor_range = 4;
    boundary = [1,img_size(2),1,img_size(1)];
    for n = 1:length(U_ind)
        if U_CB(n)
            continue;
        end
        U_rgb_k = U_rgb(n,:);
        U_yx_k = U_s(n,:);
        [~,neighbor_global_ind] = getNeighborhood(U_yx_k(2),U_yx_k(1),neighbor_range,boundary,img_size,'ignore');
        neighbor_ind = map_global_U_ind(neighbor_global_ind{1});
        neighbor_ind(neighbor_ind==0) = [];
        bw = U_CB(neighbor_ind);
        neighbor_pair = FB_pairs(neighbor_ind(bw),:);
        neighbor_pair = unique(neighbor_pair,'rows');
        fitness = ColorCostFunc(neighbor_pair,F_rgb,B_rgb,U_rgb_k);
        [~,best_neighbor_ind] = min(fitness);
        FB_pairs(n,:) = neighbor_pair(best_neighbor_ind,:);
    end
    for n = 1:length(U_ind)
        if ~U_CB(n)
            continue;
        end
        U_rgb_k = U_rgb(n,:);
        U_yx_k = U_s(n,:);
        [~,neighbor_global_ind] = getNeighborhood(U_yx_k(2),U_yx_k(1),neighbor_range,boundary,img_size,'ignore');
        neighbor_ind = map_global_U_ind(neighbor_global_ind{1});
        neighbor_ind(neighbor_ind==0) = [];
        bw = U_CB(neighbor_ind);
        neighbor_pair = FB_pairs(neighbor_ind(bw),:);
        neighbor_pair = unique(neighbor_pair,'rows');
        fitness = ColorCostFunc(neighbor_pair,F_rgb,B_rgb,U_rgb_k);
        [~,best_neighbor_ind] = min(fitness);
        FB_pairs(n,:) = neighbor_pair(best_neighbor_ind,:);
    end
    [alpha,~] = FB2alpha(FB_pairs,img,trimap,0);
    fprintf(strcat('Image number ', img_dir(j).name, 'has been completed.'));
    imwrite(alpha,strcat(result_path,img_dir(j).name));
end
