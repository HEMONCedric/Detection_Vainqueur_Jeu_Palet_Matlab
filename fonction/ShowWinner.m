function []=ShowWinner(X,Y,Xc,Yc,Im)
for i=1:length(X)
    distance=sqrt(abs(Xc-X).^2+abs(Yc-Y).^2);
end
[~,index]=sort(distance,'ascend');
Xwin=X(index(1));
Ywin=Y(index(1));

figure;imagesc(Im);colormap('gray'); hold on
plot(Xwin, Ywin, 'rx','MarkerSize',16 );
end