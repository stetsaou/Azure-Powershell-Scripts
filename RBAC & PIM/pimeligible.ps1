# Use the following ps module to get all PIM eligible roles on an Azure Tenant 
#
# This module can be run only on Windows Powershell and not in PScore.*
#
#
# Run the following:
#
# Install-Module AzureADPreview -Verbose
# Import-Module AzureADPreview -Verbose
# Import-Module "<yourPath>/GetPimRoles.psm1"
# Connect-AzureAD 
# 
# $roles=Get-AzureADDirectoryRole | select DisplayName
#
# $report=foreach ($item in $roles) {Get-PIMROLEAssignment -RoleName $item.DisplayName}
#
# $report |Export-Csv $HOME/<filename>.csv 
#
function Get-PIMRoleAssignment {
        [CmdletBinding()]
        param(
            [Parameter(
                Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                ParameterSetName = 'User',
                Position  = 0
            )]
            [string[]]  $UserPrincipalName,
     
     
            [Parameter(
                Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                ParameterSetName = 'Role',
                Position  = 1
            )]
            [string]    $RoleName,
            
            
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $false,
                ValueFromPipelineByPropertyName = $false,
                Position  = 2
            )]
            [string]    $ResourceId,
     
     
            [string]    $TenantId
        )
     
        BEGIN {
            $SessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction Stop
            if (-not ($PSBoundParameters.ContainsKey('TenantId'))) {
                $TenantId = $SessionInfo.TenantId
            }
        
            $AdminRoles = Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $TenantId  | select Id, DisplayName
            $RoleId = @{}
            $AdminRoles | ForEach-Object {$RoleId.Add($_.DisplayName, $_.Id)}
        }
     
        PROCESS {
            if ($PSBoundParameters.ContainsKey('UserPrincipalName')) {
                foreach ($User in $UserPrincipalName) {
                    try {
                        $AzureUser = Get-AzureADUser -ObjectId $User | select DisplayName, UserPrincipalName, ObjectId
                        $UserRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId aadRoles -ResourceId $TenantId -Filter "subjectId eq '$($AzureUser.ObjectId)'"
     
                        if ($UserRoles) {
                            foreach ($Role in $UserRoles) {
                                $RoleObject = $AdminRoles | Where-Object {$Role.RoleDefinitionId -eq $_.id}
     
                                [PSCustomObject]@{
                                    UserPrincipalName = $AzureUser.UserPrincipalName
                                    AzureADRole       = $RoleObject.DisplayName
                                    PIMAssignment     = $Role.AssignmentState
                                    MemberType        = $Role.MemberType
                                }
                            }
                        }
                    } catch {
                        Write-Error $_.Exception.Message
                    }
                }
            }
     
            if ($PSBoundParameters.ContainsKey('RoleName')) {
               
                    $RoleMembers = @()
                    $RoleMembers += Get-AzureADMSPrivilegedRoleAssignment -ProviderId aadRoles -ResourceId $TenantId -Filter "RoleDefinitionId eq '$($RoleId[$RoleName])'" -ErrorAction Stop | select RoleDefinitionId, SubjectId, StartDateTime, EndDateTime, AssignmentState, MemberType
     
                    if ($RoleMembers) {
                        $RoleMemberList = $RoleMembers.SubjectId | select -Unique
                        $AzureUserList = foreach ($Member in $RoleMemberList) {
                            try {
                                Get-AzureADUser -ObjectId $Member | select ObjectId, UserPrincipalName
                            } catch {
                                Get-AzureADGroup -ObjectId $Member | select ObjectId, @{Name = 'UserPrincipalName'; Expression = { "$($_.DisplayName) (Group)" }}
                                $GroupMemberList = Get-AzureADGroupMember -ObjectId $Member | select ObjectId, UserPrincipalName
                                foreach ($GroupMember in $GroupMemberList) {
                                    $RoleMembers += Get-AzureADMSPrivilegedRoleAssignment -ProviderId aadRoles -ResourceId $TenantId -Filter "RoleDefinitionId eq '$($RoleId[$RoleName])' and SubjectId eq '$($GroupMember.objectId)'" | select RoleDefinitionId, SubjectId, StartDateTime, EndDateTime, AssignmentState, MemberType
                                }
                                Write-Output $GroupMemberList
                            }
                        }
     
                        $AzureUserList = $AzureUserList | select ObjectId, UserPrincipalName -Unique
                        $AzureUserHash = @{}
                        $AzureUserList | ForEach-Object {$AzureUserHash.Add($_.ObjectId, $_.UserPrincipalName)}
     
                        foreach ($Role in $RoleMembers) {
                            [PSCustomObject]@{
                                UserPrincipalName = $AzureUserHash[$Role.SubjectId]
                                AzureADRole       = $RoleName
                                PIMAssignment     = $Role.AssignmentState
                                MemberType        = $Role.MemberType
                            }
                        }
                        
                    }
                
            }
        }
     
        END {}
     
    }