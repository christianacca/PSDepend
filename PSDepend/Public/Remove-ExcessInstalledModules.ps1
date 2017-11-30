function Remove-ExcessInstalledModules {
    <#
    .SYNOPSIS
        Removes version(s) of dependent modules that Powershell will install in addition to
        the versions in the dependency specification
    
    .DESCRIPTION
        Removes version of dependent modules that Powershell will install in addition to
        the versions in the dependency specification
    
    .PARAMETER Path
        Path to a specific depend.psd1 file, or to a folder that we recursively search for *.depend.psd1 files

        Defaults to the current path
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $Path
    )
    
    process {
        $modules = Get-Dependency -Path $Path | Where-Object DependencyType -eq PSGalleryModule
        
        $targetPaths = @($modules | Select-Object -Exp Target -Unique) | Where-Object { Test-Path $_ }
        foreach ($targtPath in $targetPaths) {
            $modulesInPath = $modules | Where-Object Target -eq $targtPath
            foreach ($module in $modulesInPath) {
                $dependencyPath = Join-Path $targtPath $module.DependencyName
                Get-ChildItem $dependencyPath -Exclude ($module.Version) | 
                    Remove-Item -Recurse -Force -Confirm:$false
            }
        }
    }
}