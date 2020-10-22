function  [imgfin,P, Xg, Yg] = MaitreDetection(Im,Planche) 
% input: Image a segmenter.. 
%   Planche : image binaire de la planche .. les calculs sont seulement
%   possibles ici

% output:
%   imfin: le maitre
%   P: le polynome du contour
%   Xg,Yg :  CEntre detect'e'

%% red /  green / blue
   R=Im(:,:,1);
   G=Im(:,:,2);
   B=Im(:,:,3);
   
   %figure (2); imshow(R); title('R');
   %figure (3); imshow(G);  title('G');
   %figure (4); imshow(B);  title('B');
   
   hsv = rgb2hsv(Im); %converting the image to HSV space

   H=hsv(:,:,1);
   S=hsv(:,:,2);
   V=hsv(:,:,3);
   
   %figure (5); imshow(H); title('H');
   %figure (6); imshow(S);  title('S');
   %figure (7); imshow(V);  title('V');
%%    
   % on choisit une des images, par exemple B (blue)
   % Strat�gie : Seuillage sur plusieurs composantes de l'image et
   % combinaison binaire...
   % Trouver les barycentres des palets et une croissance de r'egions..
      
    % Pre-processing smoothing : Filtrage avec un Filtre Gaussian par exemple
    MASKGauss=1/864*[11 23 29 23 11;23 48 62 48 23; 29 62 80 62 29; 23 48 62 48 23; 11 23 29 23 11 ];
%     figure(10);mesh(MASKGauss);title('Gaussian Kernel sigma=1.41')
    B=imfilter(B,MASKGauss);
    R=imfilter(R,MASKGauss);
%     sigma=2;
%     B=iconv(B,kgauss(sigma));
%  
    %figure(11);
    imshow(B);title('B filtered image');
  %figure(12);
    imshow(R);title('R filtered image');
%    
%% BLUE 
%B=double(B).*double(Planche); 
    % A.  calcul de l'histogramme 
    NoBins=256;
    [NoPixels,NivGris]=imhist(B,NoBins);
    figure(20);plot(NivGris,NoPixels);
    grid;title('histogram');xlabel('Intensity Blue');
   
    % B. otsu's method for detecting threshold
   
    
    thresholdb = graythresh(B)  % the threshold is in the 0,1 range
    bwb = not(imbinarize(B,thresholdb)); % thresholded image
     figure; imagesc(bwb);colormap('gray'); title('Threshold RGB component image');
   
   
     %% RED
     NoBins=256;
     [NoPixels,NivGris]=imhist(R,NoBins);
     figure(20);plot(NivGris,NoPixels);
     grid;title('histogram');xlabel('Intensity Red');
     
     % B. otsu's method for detecting threshold
     
     
     thresholdb = graythresh(R)  % the threshold is in the 0,1 range
     bwr = (imbinarize(R,thresholdb)); % thresholded image
     figure; imagesc(bwr);colormap('gray'); title('Threshold RGB component ROUGE image');
     
     
     %% A.  calcul de l'histogramme 
   NoBins=256;
    [NoPixels,NivGris]=imhist(S,NoBins);
    figure(21);plot(NivGris,NoPixels);
    grid;title('histogram S ');xlabel('Saturation');

    edges = icanny(S, 2);

       
    % B. otsu's method for detecting threshold
    thresholdS = graythresh(S)  % the threshold is in the 0,1 range

    bws = imbinarize(S,thresholdS); % thresholded image
     figure; imagesc(bws);colormap('gray'); title('Threshold  Saturation image');
    
 
     
        %% A.  calcul de l'histogramme 
   NoBins=256;
    [NoPixels,NivGris]=imhist(H,NoBins);
    figure(21);plot(NivGris,NoPixels);
    grid;title('histogram H ');xlabel('Hue');

    edges = icanny(H, 2);
    figure; imagesc(edges);colormap('gray'); title('canny detector');
    sigma=2;
     edges2=isobel(H,kdgauss(sigma));
   %  edges2=iconv(H,kdgauss(sigma));
  %  edges2=iconv(H,klog(sigma));
     figure; imagesc(edges2);colormap('gray'); title('DoG detector');
      
    %% B. otsu's method for detecting threshold
    thresholdH = graythresh(H)  % the threshold is in the 0,1 range

    bwh = not(imbinarize(H,thresholdH)); % thresholded image
    bwh= bwh .* Planche; % prendre seulement les pixels qui se trouvent dqns la planche
     
    figure; imagesc(bwh);colormap('gray'); title('Threshold  H image');
    
    % on peut intersecter avec les Not(B) et R
     
%     bwh=bwh.*bwb
%         figure; imagesc(bwh);colormap('gray'); title('Threshold  Saturation image');
%  
%%

     se = strel('disk',3); 
 %    bwh = imopen(bwh,se);
     bwh = imdilate(bwh,se);
     bwh = imerode(bwh,se);
     
     eroded=imerode(bwh,se);
        figure; imagesc(bwh);colormap('gray'); title('closed binary  H image');


%%   % si jamais il y a des objets qui s'intersectent .. 
 
 %utiliser la
    % watershed trnasform
    
    D=bwdist(~bwh);
    D=-bwdist(~bwh);
    figure; imagesc(D);colormap('gray'); title('Distance Transform');
    L=watershed(D);
    
    bwh(L==0)=0
    figure; imagesc(bwh);colormap('gray'); title('Threshold  H image');
   % imshow(label2rgb(L,'jet','w'));
    
%%     
    % Pour calculer le maitre ca suffit de trouver les barycentres des
    % objets qui se trouvent dans bwh.. et trouver le plus petit
    %  il  faut eroder..?
    
    
%%  finding the Boundaries
 
[B,L] = bwboundaries(bwh,'noholes');

% Display the label matrix and draw each boundary
figure(10); imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end


%% trouver le plus petit.. c'est le maitre

min=1000;
centre=[0,0];

stats = regionprops(L,'Area','Centroid');
for k = 1:length(B)
     area = stats(k).Area;

       if area < min 
           min=area;
           centroid = stats(k).Centroid;
           centre=centroid;
%            plot(centroid(1),centroid(2),'ko');
       end
  
end
 plot(centre(1),centre(2),'ko');
centre
min

%% Region Growing pour trouver l'objet complet, 
% en partant du barycentre comme graine
% 

rayonMax=10;
threshold=0.1;
[P, J] = regionGrowing(S,[floor(centre(2)),floor(centre(1))],threshold,rayonMax);

figure;imagesc(J);colormap('gray'); hold on
St = regionprops(J,'Area','Centroid');
centroid = St.Centroid
 plot(P(:,1), P(:,2), 'LineWidth', 2)
 
 plot(centroid(1), centroid(2), 'ko')
 
hold off;
 

imgfin=J;
Xg=centroid(1); Yg= centroid(2);




%% Determine which objects are round
% Estimate each object's area and perimeter. Use these results to form a simple metric indicating the roundness of an object:
% metric = 4*pi*area/perimeter^2.
% This metric is equal to one only for a circle and it is less than one for any other shape. The discrimination process can be controlled by setting an appropriate threshold. In this example use a threshold of 0.94 so that only the pills will be classified as round. 
% Use regionprops to obtain estimates of the area for all of the objects. Notice that the label matrix returned by bwboundaries can be reused by regionprops.

stats = regionprops(L,'Area','Centroid');

threshold = 0.94;

% loop over the boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;
  perimeter = sum(sqrt(sum(delta_sq,2)));

  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;

  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;

  % display the results
  metric_string = sprintf('%2.2f',metric);

  % mark objects above the threshold with a black circle
  if metric > threshold
    centroid = stats(k).Centroid;
    plot(centroid(1),centroid(2),'ko');
  end

  text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       'FontSize',14,'FontWeight','bold');

end

title(['Metrics closer to 1 indicate that ',...
       'the object is approximately round']);
  
    
    
    
    

end
