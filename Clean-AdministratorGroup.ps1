# Clean-AdministratorGroup.ps1
# https://gist.github.com/tdannecy/daf057ab9b9280290efb34677d9c0ea8
# https://superuser.com/a/1481036

function Clean-AdministratorGroup {
    $administrators = @(
        ([ADSI]"WinNT://./Administrators").psbase.Invoke('Members') |
        ForEach-Object { 
            $_.GetType().InvokeMember('AdsPath', 'GetProperty', $null, $($_), $null) 
        }
    ) -match '^WinNT';
        
    $administrators = $administrators -replace 'WinNT://', ''
        
    $administrators | ForEach-Object {   
        if ($_ -like "$env:COMPUTERNAME/*" -or $_ -like "AzureAd/*") {
            continue;
        }
        Remove-LocalGroupMember -group 'Administrators' -member $_
    }
}
Clean-AdministratorGroup
