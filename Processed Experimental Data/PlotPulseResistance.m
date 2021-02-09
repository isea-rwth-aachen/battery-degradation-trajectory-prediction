addpath(genpath('ipso'))
lifetime=build_lifetime_items([pwd '\P001\']);
cell_names=fieldnames(lifetime);
[XData,YData] = PlotDataField('AhEla','pulse',cell_names,lifetime);
%%
figure_handle=figure('Name','Pulse resistance');
hold on;
SOCLevel=[0.9];
PulseLength=2;
PulseCurrent=-2;
NominalCapacity=1.85;

for ii=1:length(XData)
    YDataArray=cellfun(@(pulseData) getPulseResistance(pulseData,SOCLevel,PulseCurrent,PulseLength,NominalCapacity),YData{ii});
    plot(XData{ii}./NominalCapacity,YDataArray,'-*')
end

ipso('FigureFormat','pp_small_12x7','ColorStyle','None','FigureHandle', figure_handle);
ylabel('2sec Pulse resistance 2 A discharge at 90% SOC in Ohm');
xlabel('Equivalent Full cycles');
clear XData YData YDataArray ii
clear SOCLevel PulseCurrent PulseLength NominalCapacity
clear cell_names TestsetCell figure_handle
clear lifetime