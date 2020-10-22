function  [imgfin, Xg, Yg] = PlancheDetection(Im) 

% red /  green / blue
   R=Im(:,:,1);
   G=Im(:,:,2);
   B=Im(:,:,3);
   
%    figure (2); imshow(R); title('R');
%    figure (3); imshow(G);  title('G');
%    figure (4); imshow(B);  title('B');
   
   hsv = rgb2hsv(Im); %converting the image to HSV space

   H=hsv(:,:,1);
   S=hsv(:,:,2);
   V=hsv(:,:,3);
   
%    figure (5); imshow(H); title('H');
%    figure (6); imshow(S);  title('S');
%    figure (7); imshow(V);  title('V');
%    
   % on choisit une des images, par exemple B (blue)
   % Stratégie 1: Seuillage sur plusieurs composantes de l'image et
   % combinaison binaire
   
     
    % Pre-processing smoothing : Filtrage avec un Filtre Gaussian par exemple
    MASKGauss=1/864*[11 23 29 23 11;23 48 62 48 23; 29 62 80 62 29; 23 48 62 48 23; 11 23 29 23 11 ];
%     figure(10);mesh(MASKGauss);title('Gaussian Kernel sigma=1.41')
    B=imfilter(B,MASKGauss);
%     figure(11);
%     imshow(B);title('filtered image');
%    
   
    % A.  calcul de l'histogramme 
%     NoBins=256;
%     [NoPixels,NivGris]=imhist(B,NoBins);
%     figure(20);plot(NivGris,NoPixels);
%     grid;title('histogram');xlabel('Intensity Blue');
   
    % B. otsu's method for detecting threshold
    thresholdb = graythresh(B)  % the threshold is in the 0,1 range
    bwb = imbinarize(B,thresholdb); % thresholded image
%%     figure; imagesc(bwb);colormap('gray'); title('Threshold RGB component image');
   
   
     % A.  calcul de l'histogramme 
    NoBins=256;
%     [NoPixels,NivGris]=imhist(S,NoBins);
%     figure(21);plot(NivGris,NoPixels);
%     grid;title('histogram S ');xlabel('Saturation');

       
    % B. otsu's method for detecting threshold
    thresholdS = graythresh(S)  % the threshold is in the 0,1 range
    bws = imbinarize(S,thresholdS); % thresholded image
 %%   bws = imbinarize(S,thresholdS); % thresholded image
     figure; imagesc(bws);colormap('gray'); title('Threshold  Saturation image');
    
 
%% Background removal
    % opening (dilatation to remove disks then erosion)
    str_element=strel('disk',15);
    fond=imopen(B,str_element);

%     figure(12); imagesc(fond);colormap('gray');

    NoBins=256;
%     [NoPixels,NivGris]=imhist(fond,NoBins);
%     figure(13);plot(NivGris,NoPixels);
%     grid;title('histogram fond');xlabel('Intensity');
%     
    ss=imbinarize(fond, graythresh(fond));
%     figure(25);imagesc(ss); colormap('gray'); title('Threshold Background image');
    planche = imfill(ss,'holes');
     se = strel('disk',3);
    planche = imclose(planche,se);
%     figure(27);imagesc(planche); colormap('gray'); title('Planche');
    [Xg, Yg] = find_barycentre(planche);
    imgfin =  planche;

end
