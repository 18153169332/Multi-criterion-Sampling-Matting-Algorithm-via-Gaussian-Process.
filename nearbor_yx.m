function x = nearbor_yx(x,y,k)
ymin = y-k;
ymax = y+k;
xmin = x-k;
xmax = x+k;
[X,Y] = meshgrid(ymin:ymax,xmin:xmax);

for i = 1:(k*2+1)^2
    x(i,1) = X(i);
    x(i,2) = Y(i);
end


