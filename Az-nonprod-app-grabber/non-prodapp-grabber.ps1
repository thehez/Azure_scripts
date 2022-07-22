$APIVersion = ((Get-AzResourceProvider -ProviderNamespace Microsoft.Web).ResourceTypes `
| Where-Object ResourceTypeName -eq sites).ApiVersions[0]
$subscriptionID = Get-AzSubscription -TenantId [% TENANT ID %]
foreach($id in $subscriptionID){
    Select-AzSubscription $id
   
    $Webapps = Get-AzWebApp | where-object {($_.name -like "*PreProd*") `
    -or ($_.name -like "*Dev*") -or ($_.name -like "*DevOps*") -or ($_.name -like "*Test*")  -or ($_.name -like "*UAT*") -or ($_.name -like "*Acc*")}
    foreach($Webapp in $webapps){
        $WebAppName = $WebApp.Name
        $WebAppRGName = $WebApp.ResourceGroup

        $WebAppConfig = (Get-AzResource -ResourceType Microsoft.Web/sites/config `
        -ResourceName $WebAppName -ResourceGroupName $WebAppRGName -ApiVersion $APIVersion)
        $IpSecurityRestrictions = $WebAppConfig.Properties.ipsecurityrestrictions
        if ($WebAppConfig.Properties.ipSecurityRestrictions.ipAddress -eq "Any" `
        -and $WebAppConfig.Properties.ipSecurityRestrictions.action -eq "Allow" ) {
            Write-Output "[+] public Non-prod App Service found: $WebAppName" 
            Write-Output "$WebAppName"  | Out-File -Append "public-nonprod_appservices.txt"
             
        }
    }
}