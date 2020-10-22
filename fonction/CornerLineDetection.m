function [ImRes,X,Y]=CornerLineDetection(Im)
X=[1,1,length(Im),length(Im)];
Y=[1,size(Im,1),1,size(Im,1)];
%%
B=Im(:,:,3);
hsv = rgb2hsv(Im); 
S=hsv(:,:,2);
MASKGauss=1/864*[11 23 29 23 11;23 48 62 48 23; 29 62 80 62 29; 23 48 62 48 23; 11 23 29 23 11 ];
B=imfilter(B,MASKGauss);
thresholdb = graythresh(B);  % the threshold is in the 0,1 range
bwb = imbinarize(B,thresholdb); % thresholded image
thresholdS = graythresh(S); % the threshold is in the 0,1 range
bws = imbinarize(S,thresholdS); % thresholded image
figure; imagesc(bwb);colormap('gray'); title('Threshold  Saturation image');
%%
imgfiltre=(bwb & bws);
figure(5); 
imshow(imgfiltre);
%%
erosion = strel('cube',5);
imgerode = imerode(imgfiltre,erosion);
erosion = strel('cube',5);
imgerode = imdilate(imgfiltre,erosion);
figure(6); 
imshow(imgerode);
%%
imfinal=bwmorph(imgerode,'remove');
imshow(imfinal);
%%
[H,T,R] = hough(imfinal);
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(imfinal,T,R,P);
figure, imshow(imfinal), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
%%
xy=zeros(2,2);
i=1;
figure, imshow(imfinal), hold on
for k = 1:2:2*length(lines)
   xy(k:k+1,:) = [lines(i).point1; lines(i).point2];
   plot(xy(k:k+1,1),xy(k:k+1,2),'LineWidth',2,'Color','green');
   i=i+1;
end
%% 
index=1;
for i=1:length(lines)
    if abs(lines(i).theta)> 70
        coeffligne(i,1)=(xy(index+1,2)-xy(index,2))/(xy(index+1,1)-xy(index,1));
        coeffligne(i,2)=xy(index,1);
        coeffligne(i,3)=xy(index,2);
        index=index+2;
    else
        coeffcolonne(i,1)=(xy(index,1)-xy(index+1,1))/(xy(index+1,2)-xy(index,2));
        coeffcolonne(i,2)=xy(index,2);
        coeffcolonne(i,3)=xy(index,1);
        index=index+2;
    end
end
imageligne=zeros(345 ,367);
imagecolonne=zeros(345 ,367);
%%
for i=1:length(lines)
    if coeffligne(i,2)~=0
        for k=1:size(imageligne,2)
            imageligne(round(((k-coeffligne(i,2))*coeffligne(i,1))+coeffligne(i,3)),k)=1;
        end
    else
        for k=1:size(imagecolonne,1)
            imagecolonne(k,round(((coeffcolonne(i,2)-k)*coeffcolonne(i,1))+coeffcolonne(i,3)))=1;
        end
    end
end
%%
ImRes=imageligne | imagecolonne;
imagesc(ImRes)
ImRes=imageligne & imagecolonne;
[coiny,coinx]=find(ImRes);
for i=1:length(coinx)
     X(length(X)+1)=coinx(i);
     Y(length(Y)+1)=coiny(i);
end
figure;imagesc(Im);colormap('gray'); hold on
plot(X,Y, 'ro')
