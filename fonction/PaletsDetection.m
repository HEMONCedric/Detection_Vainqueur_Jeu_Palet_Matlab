function [ImPalets,X,Y]=PaletsDetection(Im,ImRes)
hsv = rgb2hsv(Im); %converting the image to HSV space
H=hsv(:,:,1);
S=hsv(:,:,2);
V=hsv(:,:,3);
%%
MASKGauss=1/864*[11 23 29 23 11;23 48 62 48 23; 29 62 80 62 29; 23 48 62 48 23; 11 23 29 23 11 ];
H=imfilter(H,MASKGauss);
%%
NoBins=256;
[NoPixels,NivGris]=imhist(H,NoBins);
figure(21);plot(NivGris,NoPixels);
grid;title('histogram H ');xlabel('Hue');
%%
edges = icanny(H, 2);
figure; imagesc(edges);colormap('gray'); title('canny detector');
sigma=2;
edges2=isobel(H,kdgauss(sigma));
%%
figure; imagesc(edges2);colormap('gray'); title('DoG detector');
thresholdH = graythresh(H)  % the threshold is in the 0,1 range
bwh = not(imbinarize(H,thresholdH)); % thresholded image
bwh= bwh .* ImRes; % prendre seulement les pixels qui se trouvent dqns la planche
figure; imagesc(bwh);colormap('gray'); title('Threshold  H image');
%%
se = strel('disk',5); 
bwh = imerode(bwh,se);
bwh = imdilate(bwh,se)
figure; imagesc(bwh);colormap('gray'); title('closed binary  H image');
%%
D=bwdist(~bwh);
D=-bwdist(~bwh);
figure; imagesc(D);colormap('gray'); title('Distance Transform');
%%
L=watershed(D);
bwh(L==0)=0;
figure; imagesc(bwh);colormap('gray'); title('Threshold  H image'); 
imagefinal=bwh;
%%figure;imagesc(imagefinal);colormap('gray'); 
se = strel('disk',2); 
imagefinal = imerode(imagefinal,se);
%%figure; imagesc(imagefinal);colormap('gray'); title('closed binary  H image');
se = strel('disk',2); 
ImPalets = imdilate(imagefinal,se);
figure; imagesc(ImPalets);colormap('gray'); title('closed binary  H image');
%%
imagebary =  bwmorph(imagefinal,'shrink',Inf);
figure; imagesc(imagebary);colormap('gray'); title('closed binary  H image');
[Y,X]=find(imagebary==1);

end