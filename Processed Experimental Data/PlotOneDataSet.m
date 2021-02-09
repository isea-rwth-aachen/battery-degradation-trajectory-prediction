addpath(genpath('ipso'))
lifetime=build_lifetime_items([pwd '\P001\'],'lean');%only small data loaded (no pulses, temperatures)
% lifetime=build_lifetime_items([pwd '\P001\']);
cell_names=fieldnames(lifetime);
[XData,YData] = PlotDataField('AhEla','CapDCH1',cell_names,lifetime);

NominalCapacity=1.85;
%%
figure_handle=figure('Name','Capacity');
hold on;


for ii=1:length(XData)
    plot(XData{ii}./NominalCapacity,YData{ii}./NominalCapacity,'-x')

end
clear ii 
ipso('FigureFormat','pp_small_12x7','ColorStyle','None','FigureHandle', figure_handle);


ylim([0 1.1]);
ylabel('Remaining Capacity Ah_a_c_t/Ah_n_o_m');
xlabel('Equivalent Full cycles');
clear XData YData YDataArray
clear NominalCapacity figure_handle cell_names
% clear lifetime