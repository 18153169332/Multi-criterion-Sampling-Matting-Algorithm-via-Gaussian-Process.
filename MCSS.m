function [x_pp,bpp] = MCSS(U_rgb,F_rgb,B_rgb,U_s,F_s,B_s,u_f,u_b,epsion,func1,func2,func3)

% U_idx is unkonwn pixel index
% U_rgb is RGB value of unkonwn pixel
% F_rgb is RGB value of foreground pixel
% B_rgb is RGB value of background pixel
% U_s F_s B_S £ºCoordinates of unknown pixels, foreground pixels, and background pixels.
% u_f,u_b:Distance from unknown pixels to foreground and background.
N=50;
k=1:N;


%% Calculate color and distance differences.
color_f = sum(abs(U_rgb- F_rgb),2);
color_b = sum(abs(U_rgb- B_rgb),2);


dist_f = sqrt((U_s(1,1)- F_s(:,1)).^2+(U_s(1,2)- F_s(:,2)).^2);
dist_b = sqrt((U_s(1,1)- B_s(:,1)).^2+(U_s(1,2)- B_s(:,2)).^2);

%%Ranking of color and distance differences.
[first_f,indf ]= sort(color_f,'ascend');
[first_b,indb ]= sort(color_b,'ascend');



%%Select the pixel with the minimum distance from a set of pixels with similar color differences - foreground.

sf = [];
for i = 1:length(first_f)
    if abs(first_f(1)- first_f(i)) < epsion
        sf(i,:) = indf(i);
    end
end


[~,idf]= sort(dist_f(sf),'ascend');
[~,idfu]= sort(u_f(sf),'ascend');

if numel(sf) < N
    Fs(:,1)= sf(idf);
    Fu(:,1)= sf(idfu);
else
    Fs(:,1)= sf(idf(k));
    Fu(:,1)= sf(idfu(k));
end

%%Select the pixel with the minimum distance from a set of pixels with similar color differences - background
sb = [];
for j = 1:length(first_b)
    if abs(first_b(1)- first_b(j)) < epsion
        sb(j,:) = indb(j);
    end
end

[~,idb] = sort(dist_b(sb),'ascend');
[~,idbu]= sort(u_b(sb),'ascend');

if numel(sb) < N
    Bs(:,1)= sb(idb);
    Bu(:,1)= sb(idbu);
else
    Bs(:,1)= sb(idb(k));
    Bu(:,1)= sb(idbu(k));
end



%% Distance to Color

[first_xf,indxf ]= sort(dist_f,'ascend');
[first_xb,indxb ]= sort(dist_b,'ascend');

sxf = [];
for i = 1:length(first_xf)
    if abs(first_xf(1)- first_xf(i)) < epsion
        sxf(i,:) = indxf(i);
    end
end

[~,idxf]= sort(color_f(sxf),'ascend');
if numel(sxf) < N
    Fx(:,1)= sxf(idxf);
else
    Fx(:,1)= sxf(idxf(k));
end

sb = [];
for j = 1:length(first_xb)
    if abs(first_xb(1)- first_xb(j)) < epsion
        sxb(j,:) = indxb(j);
    end
end

[~,idxb]= sort(color_b(sxb),'ascend');
if numel(sxb) < N
    Bx(:,1)= sxb(idxb);
    
else
    Bx(:,1)= sxb(idxb(k));
end

FS = unique([Fs;Fx;Fu]);
BS = unique([Bs;Bx;Bu]);
sp = [];
pp = [];
for j = 1:numel(FS)
    for j1 = 1:numel(BS)
        sp = [sp;FS(j) BS(j1)];
    end
end
x_pp_ind = randperm(length(sp),50);
x_pp = sp(x_pp_ind,:);

[fit_valur,ind1]= sort(func1(sp),'ascend');
for q = 1:length(ind1)
    if fit_valur(q) > func1(sp(ind1(1),:))+ 1
        break;
    end
    pp(q,:) = sp(ind1(q),:);
end

[fit_valur2,ind2]= sort(func2(sp),'ascend');
for q = 1:length(ind1)
    if fit_valur2(q) > func2(sp(ind2(1),:))+ 1
        break;
    end
    pp(q,:) = sp(ind2(q),:);
end


[~,ind3]= min(func3(pp));
bpp = pp(ind3(1),:);


end