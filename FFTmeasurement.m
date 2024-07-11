close; clear all; clc;

data= readtable('T0050CH1.csv');

data1= readtable('T0051CH1.csv');
data2= readtable('T0052CH1.csv');
data3= readtable('T0053CH1.csv');
data4= readtable('T0054CH1.csv');

Time = [0:0.00000320002:.2];
Fs = length(Time)/.2; %signal frequency is sample length over time 1/s units
T = 1/Fs; %Sampling period
L = length(Time); %sample length


VelocityB = table2array(data(62513:125012,"Y")); %background for silicone 6mm dampener
VelocityB = smoothdata(VelocityB,"SmoothingFactor",1);
VelocityB = (VelocityB)*25; %adjustment to make graph centered at zero and multiplied by velocity range 25 mm/Vs used to collect data
VelocityB = detrend(VelocityB);

AmpB = cumtrapz(Time, VelocityB);
AmplitudeB = detrend(AmpB);


FFTB=fft(AmplitudeB);


Velocityt(:,1) = table2array(data1(62513:125012,"Y"));
Velocityt(:,2) = table2array(data2(62513:125012,"Y")); %2Volts for silicone 6mm dampener
Velocityt(:,3) = table2array(data3(62513:125012,"Y")); %%3V silicone dampener 6mm Velocity
Velocityt(:,4)= table2array(data4(62513:125012,"Y")); %%4V silicone dampener 6mm

for i = 1:4

% Velocity = smoothdata(Velocity,"rlowess",10);
Velocity = smoothdata(Velocityt(:,i));
Velocity = (Velocity)*25;


 figure
 plot(Time, Velocity,"LineWidth",2);
 hold on
 plot(Time, VelocityB,"LineWidth",2);
 ylim([-500 500]);
 xlabel('Time(s)');
 ylabel('Velocity (mm/s)');
 title(['Velocity vs Time for ' num2str(i) 'V']);
 legend('Velocity','Background');

Amp = cumtrapz(Time, Velocity);
Amplitude = detrend(Amp);

Max = islocalmax(Amplitude,'SamplePoints',Time);
Min = islocalmin(Amplitude,'SamplePoints',Time);
Maxmean = mean(Amplitude(Max));
Minmean = mean(Amplitude(Min));
avgdispl = (abs(Maxmean)+abs(Minmean))/2;

figure
subplot(2,1,1)
plot(Time, Amplitude,"LineWidth",2);
hold on
plot(Time, AmplitudeB,"LineWidth",2);
plot(Time(Max),Amplitude(Max), 'r*');
plot(Time(Min),Amplitude(Min), 'g*');
txt = ['Average Amplitude: ' num2str(avgdispl) 'mm'];
text(.06, .02, txt)

xlabel('Time(s)');
ylabel('Amplitude(mm)');
title(['Amplitude vs Time for ' num2str(i) 'V']);
legend('Amplitude','Background');

 FFT=fft(Amplitude);

% -abs(FFTB)
 FFTfinal = abs(FFT./L)-abs(FFTB./L); %removed background FFT from calculated FFT
 FFTfinal = FFTfinal(1:L/2+1);
 FFTfinal(2:end-1) = 2*FFTfinal(2:end-1);
 FFTfinalgraph(:,i) = FFTfinal;

%  Fs/L*(0:(L/2))
 subplot(2,1,2);
 plot(Fs/L*(0:(L/2)), FFTfinal,"LineWidth",2);
 xlabel('Frequency (Hz)');
 ylabel('|FFT| (mm)');
 xlim([0 300]);
 title(['FFT for ' num2str(i) 'V']);
end

 figure

 plot(Fs/L*(0:(L/2)),FFTfinalgraph(:,1),"LineWidth",2);
 hold on
 plot(Fs/L*(0:(L/2)),FFTfinalgraph(:,2),"LineWidth",2);
 plot(Fs/L*(0:(L/2)),FFTfinalgraph(:,3),"LineWidth",2);
 plot(Fs/L*(0:(L/2)),FFTfinalgraph(:,4),"LineWidth",2);
 
 xlabel('Frequency (Hz)');
 ylabel('|FFT| (mm)');
 xlim([0 400]);
 legend('1V','2V','3V','4V');
 title('FFT');
