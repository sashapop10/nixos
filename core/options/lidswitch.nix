{
  services.logind = {
    lidSwitch = "ignore";
    extraConfig = ''
      HandlePowerKey=ignore
    '';
  };

  services.acpid = {
    enable = true;
    lidEventCommands = ''
      export PATH=$PATH:/run/current-system/sw/bin

      lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
      if [ $lid_state = "closed" ]; then
        # Set brightness to zero
        echo 0  > /sys/class/backlight/acpi_video0/brightness
      else
        # Reset the brightness
        echo 50  > /sys/class/backlight/acpi_video0/brightness
      fi
    '';

    powerEventCommands = ''
      systemctl suspend
    '';
  };
}
