function cost_c = ...
ColorCostFunc( x,F_rgb,B_rgb,U_rgb)%,F_s,B_s)
%,U_s,F_mindist,B_mindist)
%COSTFUNC Fitness function of alpha matting
%   Detailed explanation goes here
%     if size(x,1)>1
%         if length(x) == 2
%             x= x';
%         else
%             error('haha');
%         end
%     end

%     if size(U_rgb,1) == 1
%         U_rgb = repmat(U_rgb,size(x,1),1);
%         U_s = repmat(U_s,size(x,1),1);
%     end
    x = round(x);
    x_F = x(:,1); x_B = x(:,2);
    
    Fx_rgb = F_rgb(x_F,:);
    Bx_rgb = B_rgb(x_B,:);
%     Fx_s =  F_s(x_F,:);
%     Bx_s =  B_s(x_B,:);
    % Alpah
    Fx_Bx_rgb = Fx_rgb - Bx_rgb;
    est_alpha = sum((U_rgb - Bx_rgb).*Fx_Bx_rgb,2)./(sum(Fx_Bx_rgb.*Fx_Bx_rgb,2)+1);
    est_alpha(est_alpha>1) = 1;
    est_alpha(est_alpha<0) = 0;
    % Chromatic distortion
    cost_c  = norm2(U_rgb-(est_alpha.*Fx_rgb+(1-est_alpha).*Bx_rgb));

end
