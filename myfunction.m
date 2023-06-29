function sp = myfunction(U_idx,U_rgb,F_rgb,B_rgb,U_s,F_s,B_s,u_f,u_b,epsion,N)
%The parameter epsilon determines the number of samples selected.

k = (1:N)';
%% 颜色和距离差的排�?
color_f = sum(abs(U_rgb(U_idx,:)- F_rgb),2);
color_b = sum(abs(U_rgb(U_idx,:)- B_rgb),2);

dist_f = sqrt((U_s(U_idx,1)- F_s(:,1)).^2+(U_s(U_idx,2)- F_s(:,2)).^2);
dist_b = sqrt((U_s(U_idx,1)- B_s(:,1)).^2+(U_s(U_idx,2)- B_s(:,2)).^2);
%% 颜色和距离差的排�?
[first_f,indf ]= sort(color_f,'ascend'); 
[first_b,indb ]= sort(color_b,'ascend');
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
%% ����->��ɫ?
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



%% 距离=》颜色�?�纹�?

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

FS = [Fs;Fx;Fu];
BS = [Bs;Bx;Bu];

sp = [];
for j = 1:numel(FS)
    for j1 = 1:numel(BS)
        sp = [sp;FS(j) BS(j1)];
    end
end



end