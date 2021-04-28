Fs = 100;
Tsamp = 1/Fs;
a=value;
x1=a(1:6001);
x1=x1-mean(x1);
t = (0:length(x1)-1)*Tsamp; 
figure(6);
plot(t,x1);xlabel('Time (seconds)');ylabel('Signal');
fcut=0.5;
Hd = designfilt('lowpassfir','FilterOrder',40,'CutoffFrequency',fcut, ...
       'DesignMethod','window','Window',{@kaiser,5},'SampleRate',Fs);
fvtool(Hd);
y1 = filter(Hd,x1);
[b,a1] = butter(3,0.3/50,'low');
freqz(b,a1);
y2=filter(b,a1,x1);
figure(1);
plot(t,y1,t,y2);
t3=t(t>=0);
y3=y2(t>=0);
figure(2);
plot(t3,y3);
y3=y3-mean(y3);

hoursPerDay =170;
coeff24hMA = ones(1, hoursPerDay)/hoursPerDay;

y4= filter(coeff24hMA, 1, y3);
figure(3);
plot(t3,y4);xlabel('Time (seconds)');ylabel('Signal');

n=1:length(y4);
N=(max(y4)-mean(y4)).*sin((2*3.1416*0.75/300).*n);
%N(N<0)=abs(N(N<0));
Z=zeros(1,length(y4));
Z(1:301)=1;
N=N.*Z;
[acor,lag] = xcorr(y4,N);
% figure;
% plot(lag,acor);
% a3 = gca;
% a3.XTick = sort([-10000:1000:10000]);
lag2=lag(lag>=0);
acor2=acor(find(lag>=0));
figure(4);
plot(lag2,acor2);xlabel('Time (seconds)');ylabel('Signal');%ylim([min(acor2) 4]);

[envHigh, envLow] = envelope(acor2,70,'peak');
envMean=(envHigh+envLow)/2;
acor3=acor2-min(acor2);
% figure(8);
% plot(lag2,acor2,lag2,envLow);
acor3(acor3<mean(acor3)/2)=0;
acor3=acor3/mean(acor3);
acor3=((acor3).^2)./2;
acor3=acor3.*10;
acor3(acor3<=mean(acor3)/4)=acor3(acor3<=mean(acor3)/4)./10;
acor3(acor3>=mean(acor3)*2)=(acor3(acor3>=mean(acor3)*2)./10)+mean(acor3)*2;

acor3=smooth(acor3);
figure(5);
plot(t3,acor3);xlabel('Time (seconds)');ylabel('Signal');
hold on;
kpre=1;
for k=2:length(acor3)-1
    if (acor3(k)>acor3(k-1)&& acor3(k)>acor3(k+1)&& acor3(k)>mean(acor3)/2 && abs(t3(k)-t3(kpre))>=1)
        plot(t3(k),acor3(k),'rx');
        kpre=k;
    end
end
hold off;