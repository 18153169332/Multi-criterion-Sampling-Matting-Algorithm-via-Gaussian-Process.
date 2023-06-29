function alpha = GPMCMatting()
img_path = '..\Multi-criterion Sampling Matting Algorithm via Gaussian  Process\data\input\';
trimap_path = '..\Multi-criterion Sampling Matting Algorithm via Gaussian  Process\data\trimap\';
results_path='..\Multi-criterion Sampling Matting Algorithm via Gaussian  Process\results\';
img_dir=dir([img_path,'*.png']);
trimap_dir=dir([trimap_path,'*.png']);
epsion = 50;
%Calculation resources for different percentages.
for sample_num =[50, 100, 250, 500,1000,5000] 
    sample_size = sample_num;
    if sample_size > 100
        X_e = 1:0.1*sample_size;
    else
        X_e = 1:50;
    end
    
    for j=19
        img_url=[img_path,img_dir(j).name];
        trimap_url=[trimap_path,trimap_dir(j).name];
        img = imread(img_url);
        trimap = imread(trimap_url);
        [F_ind,B_ind,U_ind,F_rgb,B_rgb,U_rgb,F_s,B_s,U_s,F_mindist,B_mindist] = GetMattingInfo(img,trimap);
        FB_pairs=zeros(length(U_ind),2);
        CB = CheckerboardGenerator(size(trimap));
        t1=clock;
        %% selecting unkonwn pixels nearborhood pixel index
        U_dist = bwdist(trimap == 128);
        F_dist = U_dist(F_ind);F_dist_ind = find(F_dist<2);
        B_dist = U_dist(B_ind);B_dist_ind = find(B_dist<2);
        UF = F_s(F_dist_ind,:);
        UB = B_s(B_dist_ind,:);

        %%  map index of F B
        map = zeros(size(trimap));
        map(F_ind) = 1:length(F_ind);
        map(B_ind) = 1:length(B_ind);
        %%  random sampling
        x_sample = [];

        U_CB = CB(U_ind);
       parfor n = 1:length(U_ind)
            if ~U_CB(n)
                FB_pairs(n,:) = [0,0];
                continue;
            end
            %%  construct model GPR 
            U_rgb_sample=U_rgb(n,:);
            U_s_sample=U_s(n,:);
            F_mindist_sample=F_mindist(n,:);
            B_mindist_sample=B_mindist(n,:);
            pp_func1 = @(x_sample)MOEADCostFunc(x_sample,F_rgb,B_rgb,U_rgb_sample,F_s,B_s,U_s_sample,F_mindist_sample,B_mindist_sample);
            pp_func2 = @(x_sample)FuzzyCostFunc(x_sample,F_rgb,B_rgb,U_rgb_sample,F_s,B_s,U_s_sample,F_mindist_sample,B_mindist_sample);
            pp_func3 = @(x_sample)ColorCostFunc(x_sample,F_rgb,B_rgb,U_rgb_sample);            
            [x_sample,ps]= MCSS(U_rgb_sample,F_rgb,B_rgb,U_s_sample,F_s,B_s,F_dist,B_dist,epsion,pp_func1,pp_func2,pp_func3);
            FB_pairs(n,:) = gprmode(pp_func1,x_sample,X_e,trimap,ps);  %fitness:适应值；x_sample;样本；X_e：精英像素对个数序列；FB_s：领域像素对
            
        end
        map_global_U_ind =zeros(size(trimap));
        map_global_U_ind(U_ind) = 1:length(U_ind);
        img_size = size(trimap);
        neighbor_range = 8;
        boundary = [1,img_size(2),1,img_size(1)];
        for n = 1:length(U_ind)
            if U_CB(n)
                continue;
            end
            U_rgb_k = U_rgb(n,:);
            U_yx_k = U_s(n,:);
            F_mindist_k = F_mindist(n,:);
            B_mindist_k = B_mindist(n,:);
            [~,neighbor_global_ind] = getNeighborhood(U_yx_k(2),U_yx_k(1),neighbor_range,boundary,img_size,'ignore');
            neighbor_ind = map_global_U_ind(neighbor_global_ind{1});
            neighbor_ind(neighbor_ind==0) = [];
            bw = U_CB(neighbor_ind);
            neighbor_pair = FB_pairs(neighbor_ind(bw),:);
            neighbor_pair = unique(neighbor_pair,'rows');
            fitness = MOEADCostFunc(neighbor_pair,F_rgb,B_rgb,U_rgb_k,F_s,B_s,U_yx_k,F_mindist_k,B_mindist_k);
            [~,best_neighbor_ind] = min(fitness);
            FB_pairs(n,:) = neighbor_pair(best_neighbor_ind,:);
        end
        for n = 1:length(U_ind)
            if ~U_CB(n)
                continue;
            end
            U_rgb_k = U_rgb(n,:);
            U_yx_k = U_s(n,:);
            F_mindist_k = F_mindist(n,:);
            B_mindist_k = B_mindist(n,:);
            [~,neighbor_global_ind] = getNeighborhood(U_yx_k(2),U_yx_k(1),neighbor_range,boundary,img_size,'ignore');
            neighbor_ind = map_global_U_ind(neighbor_global_ind{1});
            neighbor_ind(neighbor_ind==0) = [];
            bw = U_CB(neighbor_ind);
            neighbor_pair = FB_pairs(neighbor_ind(bw),:);
            neighbor_pair = unique(neighbor_pair,'rows');
            fitness = MOEADCostFunc(neighbor_pair,F_rgb,B_rgb,U_rgb_k,F_s,B_s,U_yx_k,F_mindist_k,B_mindist_k);
            [~,best_neighbor_ind] = min(fitness);
            FB_pairs(n,:) = neighbor_pair(best_neighbor_ind,:);
        end
        [alpha,fitness] = FB2alpha(FB_pairs,img,trimap,0);
        fprintf(strcat('第:',img_dir(j).name,'张图已完成'));
        imwrite(alpha,strcat(results_path,img_dir(j).name));
    end
end