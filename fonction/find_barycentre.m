function [ X,Y ] = find_barycentre( img )
% Donne les coorddonées du barycentre de l'image.
% L'objet doit être en blanc (255), le reste en noir (0)
barx = 0;
bary = 0;
[Nx,Ny] = size(img);

index = find(img > 0.8); 
[nx,ny] = size(index);

for i=1:Nx
    for j=1:Ny
        barx = barx + img(i,j)*i;
        bary = bary + img(i,j)*j;
    end
end
X = floor(barx/(nx*ny));
Y = floor(bary/(nx*ny));
end

