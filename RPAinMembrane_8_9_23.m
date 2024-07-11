clear; close all; clc;

% Set defaults
set(0,...
    'DefaultAxesFontSize',16,...
    'DefaultTextFontSize',16,...
    'DefaultLineMarkerSize',12,...
    'DefaultLineLineWidth', 1);

%% User inputs
namefile = ['NTC-mix'];

qq = 1; % First frame
background_images = 4; %one image per 5 sec so 4-8 = 20-40 seconds

%% Crop image
% figure(1)
preview=mimread('',namefile,40,1);
imshow(preview,[0 520])
h1 = drawline('SelectedColor','blue');
points = h1.Position;
slope = (points(1,2)-points(2,2))/(points(1,1)-points(2,1));
angle = tanh(slope);
degangle = rad2deg(angle);
I2 = imrotate(preview,degangle);
namefile
imshow(I2,[0 520])
rect = getrect();
xmin = double(rect(1));  
ymin = double(rect(2));   
height = double(rect(4));     
L = double(rect(3));  

%% Compile image data

% Establish image used for background subtraction

backtemp1=mimread('',namefile,1,1);  % read in multiple image tiff file
backtemp21 = imrotate(backtemp1,degangle);
background1 = imcrop(backtemp21,[xmin ymin L height]);

% backtemp11=double(mimread('',namefile,1,1));  % read in multiple image tiff file
% backtemp111 = imrotate(backtemp11,degangle);
% background11 = imcrop(backtemp111,[xmin ymin L height]);

k = length(imfinfo([namefile '.tif'])); %number of frames in data stack
i=1;
sz= size(background1);
backgnd = zeros(sz,'uint16');

for m = qq:background_images
    backtemp=mimread('',namefile,m,1);  % read in multiple image tiff file
    backtemp2 = imrotate(backtemp,degangle);
    background = imcrop(backtemp2,[xmin ymin L height]);
    backgnd = backgnd + background;
end

backgnd1 = backgnd./background_images;

for j=qq:k

    Image=mimread('',namefile,j,1); % read in multiple image tiff file
    I2 = imrotate(Image,degangle);
    X=imcrop(I2,[xmin ymin L height])-backgnd1; % crop and back subtract

    bulkfluor(i) = sum(sum(X)); % calculate total fluorescence
%     figure(1);
    set(gcf,'Position',[700, 540 , 230, 180]); % had to do this to solve a bug
%     imshow(X,[]);
    F(i) = getframe(gcf); % store image frames for video

    i=i+1;
end

% Generate video of background subtacted images
% v = VideoWriter(namefile,'MPEG-4');
% v.FrameRate = 5;  % Denotes how many frames per second to export video
% open(v); 
% writeVideo(v,F);
% close(v)

% Plot bulk fluorescence over time
% bulkfluor2 = [zeros(1,qq-1) bulkfluor]; % Append 0 fluor as first 4 mins

% bulkfluor(1:90) = 0;

% A2 = unique(bulkfluor(:));
% out = A2(2);
% index = find(bulkfluor == out);
% bulkfluor(1:index)=0;

figure
t = linspace(0,20,length(bulkfluor)); % Create time series over 20 mins
plotscale = fastsmooth(bulkfluor,15,1,1)/280000;
% plotscale = smoothdata(plotscale,'movmean',[5 5]); %not needed
plot(t,plotscale-4,'linewidth',1.5) % "fastsmooth smoothes the plotted curve
set(gca,'linewidth',1)
ylabel('Fluorescence (a.u.)')
xlabel('Time (min)')
% ylim([-max(bulkfluor)*.1,max(bulkfluor)*1.1])
ylim([-.1,5]);

