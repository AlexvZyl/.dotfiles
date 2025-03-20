{ config, ... }:

{
    powerManagement = {
        enable = true;
        powertop.enable = false;
        cpuFreqGovernor = "powersave";
        # cpufreq.max = 2000000;
        cpufreq.max = 10000000;
    };

    services.thermald.enable = true;
}
