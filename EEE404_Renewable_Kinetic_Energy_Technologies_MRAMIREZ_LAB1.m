%*************************************************************************%
%                               PRESENTATION
%Xi'An Jiaotong - Liverpool University
%EEE404-RENEWABLE KINETIC ENERGY TECHNOLOGIES
%Module leader: Dr. Kejun QIAN
%Department of Electrical and Electronic Engineering 
%Author: Mateo RAMÍREZ
%Master Program - Sustainable Energy Technologies
%*************************************************************************%
%*************************************************************************%
%Clean and Clear
%*************************************************************************%
clc
clear all
%*************************************************************************%
%User Data Input
%*************************************************************************%
prompt={'Project Name:','Project Location:'};
dlg_title='Project Initial Information'; 
num_lines = [1,50];
answer=inputdlg(prompt,dlg_title,num_lines);
P_N = (answer{1});                                                   
P_L = (answer{2});                                                  
%*************************************************************************%
%Load Wind Speed Data
%*************************************************************************%
%data_wind_speed_site = csvread(uigetfile('*.*'));
load data_wind_speed_site.txt
%*************************************************************************%
%Extract Wind Speed Values and Convert Matrix
%*************************************************************************%
wind_speed = data_wind_speed_site(:,4);
%*************************************************************************%
%Analysis of Initial Data
%*************************************************************************% 
%Histogram Generation
subplot(3,3,3)
histogram(wind_speed);
title('Sample Data Histogram')
xlabel('Wind Speed (m/s)')                     
ylabel('Sample Data Total')          
%Calculate Sample Size
end_wind_speed = sum(isfinite(wind_speed));
%Calculate Wind Speed Average Monthly
month_average = daily2monthly(data_wind_speed_site);
ma_x = month_average(:,2);
ma_y = month_average(:,3); 
subplot(3,1,2)
area(ma_x,ma_y)
axis([1 12 0 12]) 
xticklabels({'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'})
title('Wind Speed Montly Average')
xlabel('Month')                     
ylabel('Wind Speed (m/s)')          
%Calculate Wind Speed Average
wind_speed_avg = mean(wind_speed);
%Calculate Wind Speed Standard Deviation
wind_speed_std = std(wind_speed);
%*************************************************************************%
%Initial Data Print in Figure
%*************************************************************************%
Initial_Data = {'Project Name';'Project Location';'Total Sample Number';'Wind Speed Average'};
Data = [cellstr('XJTLU Wind Park');P_L;end_wind_speed;wind_speed_avg];
T = table(Data,'RowNames',Initial_Data);
% Get the table in string form.
TString = evalc('disp(T)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
%*************************************************************************%
%          Weibull Probability Density Function
%*************************************************************************%
%++Standard Deviation Method Factor Calculation++
k_wstdm = (wind_speed_std/wind_speed_avg)^-1.086;
c_wstdm = (wind_speed_avg)/(gamma(1+(1/k_wstdm)));
%++Method of Moments Method Factor Calculation++
k_mom = (0.9874/(wind_speed_std/wind_speed_avg))^1.0983;
c_mom = (wind_speed_avg)/(gamma(1+(1/k_mom)));
%++Method of Moments Method Factor Calculation++
wif = fitdist(wind_speed(:,1),'weibull');
k_wif = wif.B;
c_wif = wif.A; 
%*************************************************************************%
%Weibull Probability Calculation Loop
for n=1:end_wind_speed
    %Standard Deviation Method Loop
    wind_speed(n,2) = (k_wstdm/((c_wstdm^k_wstdm)))*(wind_speed(n,1)^(k_wstdm-1))*exp(-(wind_speed(n,1)/c_wstdm)^k_wstdm);
    wind_speed(n,3) = wind_speed(n,2) * 100;
    stdm_x(1,n) = wind_speed(n,1);
    stdm_y(1,n) = wind_speed(n,3);
    %Method of Moments Loop
    wind_speed(n,4) = (k_mom/((c_mom^k_mom)))*(wind_speed(n,1)^(k_mom-1))*exp(-(wind_speed(n,1)/c_mom)^k_mom);
    wind_speed(n,5) = wind_speed(n,4) * 100;
    mom_x(1,n) = wind_speed(n,1);
    mom_y(1,n) = wind_speed(n,5);
    %FitDist In-built Function
    wind_speed(n,6) = (k_wif/((c_wif^k_wif)))*(wind_speed(n,1)^(k_wif-1))*exp(-(wind_speed(n,1)/c_wif)^k_wif);
    wind_speed(n,7) = wind_speed(n,6) * 100;
    wif_x(1,n) = wind_speed(n,1);
    wif_y(1,n) = wind_speed(n,7);
end

for n=1:12
    %Coeffecient of Variation - COV (%)
    month_average(n,4) = (wind_speed_std/month_average(n,3)) * 100;
    %Standard Deviation Method Loop Monthly 
    month_average(n,5) = (k_wstdm/((c_wstdm^k_wstdm)))*(month_average(n,3)^(k_wstdm-1))*exp(-(month_average(n,3)/c_wstdm)^k_wstdm);
    %Method of Moments Loop
    month_average(n,6) = (k_mom/((c_mom^k_mom)))*(month_average(n,3)^(k_mom-1))*exp(-(month_average(n,3)/c_mom)^k_mom);
    %FitDist In-built Function
    month_average(n,7) = (k_wif/((c_wif^k_wif)))*(month_average(n,3)^(k_wif-1))*exp(-(month_average(n,3)/c_wif)^k_wif);
end
subplot(3,1,3)
    scatter(stdm_x,stdm_y,5)
    legend('STDM')
    hold on
    scatter(stdm_x,mom_y,2)
    legend('STDM','MOM')
    hold on
    scatter(wif_x,wif_y,3)
    legend('STDM','MOM','WIF')
    title('Percent of Year vs Wind Speed')
    xlabel('Wind Speed (m/s)')         
    ylabel('Percent of Year (%)')          
    hold off
