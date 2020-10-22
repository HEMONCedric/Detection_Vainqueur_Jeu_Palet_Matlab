close all;
clear all;
%% Image reading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filename ='../Data/palet-Contrast.png';
% filename2='../Data/palet.png';
filename2='palet.png';
%mire_filename ='./CorrectedImage.png';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
Im=imread(filename2);
imagesc(Im);
%% Detection planche
[ImRes,X,Y]=PlancheDetection(Im);
 
figure(2); 
imagesc(ImRes); colormap('gray'); hold on; title('barycentre');
plot(Y,X,'o');
hold off
%% Détection du contour de la planche
ES=strel('square',3);
imd=imdilate(ImRes,ES);
imContour=imd-ImRes;
imwrite(imContour,'./DetectedPlanche.png','png');
figure(3); imagesc(imContour); colormap('gray'); title ('Contour de la planche');

[x,y]=find(imContour > 0);
Perimetre1=size(x);

figure (4); imagesc(Im); hold on; plot(y,x,'.','color','white'); plot(Y,X,'o');
hold off

Planche=ImRes
%% Detection maitre/palets 
[ImMaitre,P,Xc,Yc]=MaitreDetection(Im,Planche);
%%
figure;imagesc(Im);colormap('gray'); hold on
plot(P(:,1), P(:,2), 'LineWidth', 2)
plot(Xc, Yc, 'ko');
%% Detection palets
[ImPalets,X,Y]=PaletsDetection(Im,Planche);
%% Identification du gagnant
ShowWinner(X,Y,Xc,Yc,Im); 
%% Detection des coins
[ImRes,X,Y]=CornerLineDetection(Im);
