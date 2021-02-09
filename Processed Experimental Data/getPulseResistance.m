function [PulseValue] = getPulseResistance(pulseData,SOCLevel,PulseCurrent,PulseLength,NominalCapacity)

if ~any(SOCLevel) && ~any(PulseCurrent) && ~any(PulseLength) % if everything is 0, return first value
    PulseValue=pulseData(1).resistance;
    return
end

if length(SOCLevel)==1
    SOCLevel=[SOCLevel-0.1 SOCLevel+0.1];
end

if PulseCurrent~=0
    FindPulseCurrent=round([pulseData.Current],1)==round(PulseCurrent,1);
else %find closest to 1C discharge
    CRates=round([pulseData.Current],1)/NominalCapacity;
    [~,~,idx]=unique(round(abs(CRates+1)),'stable'); %find -1C
    FindPulseCurrent=logical(idx==1)';
% minVal=CRates(idx==1)
end
FindPulseLength=[pulseData.Duration]==PulseLength;
FindPulseSOC=(1-round(abs([pulseData.Ah_act])./NominalCapacity,1)>=SOCLevel(1) & 1-round(abs([pulseData.Ah_act])./NominalCapacity,1)<=SOCLevel(2));
PulseIndex=logical(FindPulseLength.*FindPulseCurrent.*FindPulseSOC);

if sum(PulseIndex) == 1
    PulseValue=pulseData(PulseIndex).resistance;
elseif  sum(PulseIndex) == 0
    PulseValue=NaN(1,1);
    %     disp('Pulse not found or not unique')
else
    PulseValue=pulseData(PulseIndex).resistance;
    PulseValue=PulseValue(1);
end


end

