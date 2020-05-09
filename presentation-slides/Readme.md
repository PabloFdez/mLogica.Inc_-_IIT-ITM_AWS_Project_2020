# Instructions to Build Slides

These slides are built in Markdown and converted into PDF and HTML by using Pandoc, MikTex, and Beamer -- they are cross platform and cross build.

## Pre-requisites

Install these two pieces of software:  Mac or Windows

* [Pandoc for Windows and MacOS](https://github.com/jgm/pandoc/releases/tag/2.9.2.1 "Pandoc Download Website")
* [Miktex](https://miktex.org/download "Miktex download page")

Upon installation reboot your system to make sure the system paths have been adjusted.

### How to Build the Artifacts

From the command line run the script for Windows (.ps1) or for MacOS (.sh)

**Note:** you may have to allows PowerShell scripts execute permissions (windows) by typing the following command from an Administrator PowerShell prompt:

```powershell
Set-ExecutionPolicy Unrestricted
```

Execute these commands from a user-level command prompt:

```powershell
./build-slides.ps1
```

```bash
./build-slides.sh
```

On the first build MikTex will prompt you to install additional packages, go ahead and accept these packages.   The artifacts will be built in this directory and will automatically overwrite the previous version.

### Sample File

I have included a sample file, with images and sample build script that will generate a PDF and HTML.  It is a copy of some notes for a class.  You can see the Markdown in use or bullet points and code blocks

Good luck!