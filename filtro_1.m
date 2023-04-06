%% Eliminar el ruido de una señal de audio.
%by Efrain Antonio Rojas and Andres Felipe Pelaez.
clear all;
close all; 
clc;
M=1000;%numero de muestras del los filtros
n=-M:M;
[x,fs]=audioread('noisy.wav');%obtiene la señal de auidio y la frecuencia en la que se opera
[X,Omega]=freqz(x,1,65536);%respuesta en frecuencia de la señal de auidio.
figure;
plot(Omega/(2*pi)*fs,abs(X));
%% Diseño del primer filtro.
%parametro basico bw= ancho del filtro en Hz.
bw=0.03978875;%2pi=1hz=>pi/4=1/8 hz
Omc=bw/2;
Omc=2*pi*Omc/fs;
h_LP=Omc/pi*sinc(Omc*n/pi);%filtro pasa bajos general, con este filtro se pretendende diseñar todos los filtros necesarios.
h_LP=h_LP.*hanning(numel(n))';
delta_n=(n==0);%función delta
[H_LP,Om]=freqz(h_LP,1,65536);%respuesta en frecuencia del filtro
%pasa-bajos
figure;
plot(Om/(2*pi)*fs,abs(H_LP));
fc=500;%frecuencia de central del primer filtro.
Om0=2*pi*fc/fs;
h_BP=2*h_LP.*cos(n*Om0);%filtro pasa-banda.
%[H_BP,Om]=freqz(h_BP,1,65536);%respuesta en frecuencia del filtro
%pasa-banda
%plot(Om/(2*pi)*fs,abs(H_BP));
h_SB=delta_n-h_BP;%filtro supresor de banda con frecuencia central de 500Hz.
h_SB=h_SB.*hanning(numel(n))';%enventanado con la función Hanning.
[H_SB,Om]=freqz(h_SB,1,65536);%respues en frecuencia del filtro.
plot(Om/(2*pi)*fs,abs(H_SB));
%% Diseño del segundo filtro.

fc=9730;%frecuencia central del filtro.
Om0=2*pi*fc/fs;
h_BP=2*h_LP.*cos(n*Om0);%filtro pasa-banda.
h_SB1=delta_n-h_BP;%filtro rechaza-banda.
%plot(Om/(2*pi)*fs,abs(H_SB));
h_SB1=h_SB1.*hanning(numel(n))';%enventanado con hanning.
%[H_SB,Om]=freqz(h_SB,1,65536);%respuesta en frecuencia del filtro.
%plot(Om/(2*pi)*fs,abs(H_SB));

y=filter(h_SB,1,x);%primer filtro aplicado a la señal original.
y=filter(h_SB,1,y);%se realiz de nuevo el filtrado ya que la amplitud del ruido es demasido grande.
y=filter(h_SB1,1,y);%segundo filtro aplicado a la señal ya filtrada por el primer filtro.
y=filter(h_SB1,1,y);%se realiza de nuevo el filtrado ya que la potencia del ruido es excesiva.

[Y,Om]=freqz(y,1,65536);%respuesta en frecuencia de la señal de salida con el ruido atenuado.
figure;
plot(Om/(2*pi)*fs,abs(Y));
%soundsc(y,fs);%sonido de salida.