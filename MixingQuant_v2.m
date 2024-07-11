clear all; close all; clc;

%% User inputs
namefile = ["AFPol-water-nomix","AFPol-water-nomix2","AFPol-water-nomix3", "AFPol-1-5PEG-nomix", "AFPol-1-5PEG-nomix2", "AFPol-1-5PEG-nomix3", "AFPol-5PEG-nomix","AFPol-5PEG-nomix2","AFPol-5PEG-nomix3", "AFPol-1-5PEG-mix","AFPol-1-5PEGl-mix2","AFPol-1-5PEG-mix3","AFPol-5PEG-mix","AFPol-5PEG-mix2","AFPol-5PEG-mix3","AFPol-water-mix", "AFPol-water-mix2","AFPol-water-mix3"];
% "ControlNoMixingWATER","1.5%PEG","#1(5%PEG)","#1(Water)",
% namefile = {'1.5%PEG','MM&AFpol','6%PEG2','AFPol-water-nomix'};
for kk = 1:18
    clearvars -except namefile kk X2rms
%% Crop image
figure
preview=mimread('',convertStringsToChars(namefile(kk)),100,1);
% pre2 = imrotate(preview,2,"bilinear","crop");
imshow(preview,[])
h1 = drawline('SelectedColor','blue');
points = h1.Position;
slope = (points(1,2)-points(2,2))/(points(1,1)-points(2,1));
angle = tanh(slope);
degangle = rad2deg(angle);
I2 = imrotate(preview,degangle);
imshow(I2,[])
rect = getrect();
xmin = double(rect(1));  
ymin = double(rect(2));   
height = double(rect(4));     
L = double(rect(3));  

%% Compile image data

% k = length(imfinfo([namefile '.tif'])); %number of frames in data stack
i=1;
for j=1:240
    Image1=mimread('',convertStringsToChars(namefile(kk)),j,1);  % read in multiple image tiff file
    Image2=imrotate(Image1,degangle);
    imcell=imcrop(Image2,[xmin ymin L height]);
    X(:,i) = vertcat(double(imcell(:)));
    i=i+1; 
end

Xmean = mean(X,1);
X2 = (X-Xmean).^2;
X2rms(:,kk) = fastsmooth(mean(X2,1).^(.5),15,3,1);

end

Xfinal = X2rms./X2rms(1,:);

wnom= mean(Xfinal(:,[1:3]),2);
onefivenom= mean(Xfinal(:,[4:6]),2);
fivenom= mean(Xfinal(:,[7:9]),2);
onefivem= mean(Xfinal(:,[10:12]),2);
fivem= mean(Xfinal(:,[13:15]),2);
wm=mean(Xfinal(:,[16:18]),2);

% Xfinal = fastsmooth(X2rms,10,1,1)./X2rms(1,:);
% figure
time = linspace(0,20,length(X2rms));
figure
hold on

plot(time,onefivenom,'linewidth',2.5, 'Color', 'g','LineStyle','--');
plot(time,fivenom,'linewidth',2.5, 'Color', 'b','LineStyle','--');
plot(time,wnom,'linewidth',2.5, 'Color', 'r','LineStyle','--');

plot(time,onefivem,'linewidth',2.5, 'Color', 'g');
plot(time,fivem,'linewidth',2.5, 'Color', 'b');
plot(time,wm,'linewidth',2.5, 'Color', 'r');

set(gca,'fontsize',16,'linewidth',1.5)
xlabel('Time (min)')
ylabel('Macro-mixing index \rightarrow \langle(I-\langleI\rangle)^2\rangle^0^.^5')
% ylim([-0.1 1.1])




