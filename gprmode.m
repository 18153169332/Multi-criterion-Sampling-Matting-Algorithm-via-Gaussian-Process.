function   FB_pairs= gprmode(pp_func,x_sample,n,trimap,FB_s)

fitness = pp_func(x_sample);
[fit,ind]=sort(fitness,'ascend');
F_ind = find(trimap == 255);
B_ind = find(trimap == 0);

%fitness=prob(fitness(n));
if length(x_sample) < 50
    n = 1:length(x_sample) ;
end

%% fit
gprMdl = fitrgp(x_sample(ind(n),:),fit(n),'FitMethod','none','Standardize',1 );
fun=@(x)predict(gprMdl,x);
[~,ind]=min(fun(FB_s));
FB_pairs=fmincon(fun,FB_s(ind,:),[],[],[],[],[1 1],[length(F_ind) length(B_ind)],[],optimoptions(@fmincon,'Display', 'off'));
FB_pairs=round(FB_pairs);



