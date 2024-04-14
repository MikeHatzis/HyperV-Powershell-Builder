# HyperV-Powershell-Builder

Automate the creation of Virtual Machines and Virtual Switches for Hyper-V using PowerShell.

## Prerequisites

- Ensure you are running on a supported operating system: Hyper-V is available on 64-bit versions of Windows 10 Pro, Enterprise, and Education. It is **not** available on the Home edition.
- Make sure your system's processor supports hardware virtualization. This feature is often referred to as "Intel VT-x" or "AMD-V" for Intel and AMD processors respectively.
- Install PowerShell Core (version 6.0 or later).
- Run the script with elevated privileges (Administrator).
- Enable virtualization in your system's BIOS settings.

## Instructions

1. Open PowerShell.
2. Copy and run the script into PowerShell. Example: `\HyperV-Powershell-Builder.ps1`.
3. Follow the prompts to configure your Virtual Machine and Virtual Switch.
4. Review the displayed information about the created Virtual Machine/Virtual Switch.

## Features

- Check if Hyper-V is installed on your machine.
- Enable Hyper-V Features if not already installed.
- Interactive prompts for configuring Virtual Machine settings including:
  - Name of Virtual Machine
  - Generation Type
  - Memory (with option for Dynamic Memory)
  - Number of CPUs
  - Path for VM config files
  - Path for .vhdx file
  - Size of .vhdx file
  - Option to create a new virtual switch or use an existing one
- Displays detailed information about the created Virtual Machine.


## Note

- Ensure to review and customize the script according to your specific requirements and environment.

## Example


`# Example usage of the script:
.\HyperV-Powershell-Builder.ps1`

