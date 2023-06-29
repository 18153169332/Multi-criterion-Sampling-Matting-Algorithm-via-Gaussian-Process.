function FB_pairs = nhood(n_neighbor,U_s,F_s,B_s,map)

[m,n] = size(map);
[~,ind_F] = sort(sum(abs(U_s-F_s),2),'ascend');
[~,ind_B] = sort(sum(abs(U_s-B_s),2),'ascend');

F_y = F_s(ind_F(1),1);F_x = F_s(ind_F(1),2);
B_y = B_s(ind_B(1),1);B_x = B_s(ind_B(1),2);

k = (n_neighbor-1)/2;

F_nxy = nearbor_yx(F_x,F_y,k);
B_nxy = nearbor_yx(B_x,B_y,k);
F_p = [];
B_p = [];
for i =1:length(F_nxy)
if  F_nxy(i,1)>0 && F_nxy(i,1)<m+1 && F_nxy(i,2)>0 && F_nxy(i,2)<n+1 && map(F_nxy(i,1),F_nxy(i,2))~=0
    F_p = [F_p map(F_nxy(i,1),F_nxy(i,2))];
end
if B_nxy(i,1)>0 && B_nxy(i,1)<m+1 && B_nxy(i,2)>0 && B_nxy(i,2)<n+1 && map(B_nxy(i,1),B_nxy(i,2))~=0
    B_p = [B_p map(B_nxy(i,1),B_nxy(i,2))];
end
[S1,S2] = meshgrid(F_p,B_p);

FB_pairs = [S1(:),S2(:)];

end
