# Raw experimental data

The raw dataset consists of the data from initial characterization tests (multi-pulse test, capacity test with various C-rates, qOCV test), cycling ageing tests (high-resolution data of current, voltage, capacity, energy and temperature) and regular characterization tests (multi-pulse test, capacity test with various C-rates and qOCV test).

## Data download

https://doi.org/10.18154/RWTH-2021-04545

## Data structure

The data of each test can be found in each mat file under diga.daten.

## Variables

* AhAkku: Total ampere-hours. With predominant discharge this value becomes negative [Ah]
* AhEla: Ampere-hours of all executed discharge steps until now [Ah]
* AhLad: Ampere-hours of all executed charge steps until now [Ah]
* AhStep: Ampere-hours of the current program step [Ah]
* Energie: Total energy. With predominant discharge this value becomes negative [Wh]
* Programmdauer: Time [ms]
* Prozedur: (secondary importance) Subprogram currently running.
* Prozedurebene: (secondary importance) Level of the subprogram depth currently running.
* Schritt: The program step that was executed when creating the registry entry [/]
* Schrittdauer: Time since the beginning of the step performed when creating the registry entry [ms]
* Spannung: Voltage [V]
* Strom: Current [A]
* TempX: cell surface temperature [°C]. Number X can be neglected and is cell specific.
* WhStep: Energy of the current program step [Wh]
* Zeit: Unix timestamp
* Zustand: State of the battery tester.
* Zyklus: In programs with loop constructions the Zyklus is an information about how many repetitions of the loop the registration entry was created.
* Zyklusebene: Can be neglected. (only non-zero when the test there is a loop within a loop)
