function New-SmartGroup {
    [CmdletBinding()]
    param()
    Write-Error -Message "This function is not completed yet." -ErrorAction Stop
    <#
    .SYNOPSIS
    Creates a smart group in Airwatch.

    .DESCRIPTION
    Create a smart group in Airwatch based on the given details.

    .NOTES
[ base url: /API/mdm , api version: 1 ]
post /smartgroups

type: 2
rootLg: 707

__RequestVerificationToken=bTe8caAT9XaaaydZUQsvKPrMxvBPqAH6Q_ynaBC44rKiCrywR6jolsBLJrlM0KXXczaeBZ7BrLklWZ1gqM98WqYuvEGw7T7ykG-9a3-whg6Ox_j9yehP7aZjSWhkPox8VviuJXqk25KhwNsbLz7Qyw2
&Name=Test
&Id=0
&RootLocationGroupId=707
&SmartGroupType=Reusable
&AssignedEntitiesCount=0
&IsQuickAddSmartGroup=False
&IsRuleLengthPreExceeded=False
&CriteriaType=UserDevice
&DeviceUserMaxLimit=500
&DeviceUserExistingCount=0
&UserCriteria.Items.Index=82d1f21d-0e24-4e0c-bf86-80ada711239c
&UserCriteria.Items%5B82d1f21d-0e24-4e0c-bf86-80ada711239c%5D.Selected=True
&UserCriteria.Items%5B82d1f21d-0e24-4e0c-bf86-80ada711239c%5D.Value=44564
&LivePreview=True&Save=Save

{
    "Name": "All Devices",
    "CriteriaType": "All",
    "ManagedByOrganizationGroupId": "1",
    "OrganizationGroups": [
        {
            "Name": "Organization Group Name",
            "Id": "576",
            "Uuid": "5F926C4A-DA3D-4490-9478-A8792DBD249A"
        }
    ],
    "UserGroups": [
        {
            "Name": "User Group Name",
            "Id": "123"
        }
    ],
    "Tags": [
        {
            "Id": "123",
            "Name": "Software"
        }
    ],
    "Ownerships": [
        "Text value"
    ],
    "Platforms": [
        "Text value"
    ],
    "Models": [
        "Text value"
    ],
    "OperatingSystems": [
        {
            "DeviceType": "Android",
            "Operator": "GreaterThan",
            "Value": "Android 2.2.1"
        }
    ],
    "UserAdditions": [
        {
            "Id": "512",
            "Name": "TestUser"
        }
    ],
    "DeviceAdditions": [
        {
            "Id": "123",
            "Model": "Android",
            "Username": "awuser"
        }
    ],
    "UserExclusions": [
        {}
    ],
    "DeviceExclusions": [
        {}
    ],
    "UserGroupExclusions": [
        {}
    ],
    "ManagementTypes": [
        "Text value"
    ],
    "EnrollmentCategories": [
        "Text value"
    ],
    "OEMAndModels": [
        {
            "OEM": {
                "Id": "123",
                "Name": "Dell"
            },
            "Models": [
                {
                    "Id": "123",
                    "Name": "Dell XPS 15"
                }
            ]
        }
    ],
    "CPUArchitectures": [
        "Text value"
    ]
}


    .EXAMPLE

{
    "Name": "Allow: Managed to Unmanaged",
    "CriteriaType": "All",
    "ManagedByOrganizationGroupId": "707",
    "OrganizationGroups": [
        {
            "Name": "Organization Group Name",
            "Id": "576",
            "Uuid": "5F926C4A-DA3D-4490-9478-A8792DBD249A"
        }
    ],
    "UserGroups": [
        {
            "Name": "User Group Name",
            "Id": "123"
        }
    ],
    "Tags": [
        {
            "Id": "123",
            "Name": "Software"
        }
    ],
    "Ownerships": [
        "Text value"
    ],
    "Platforms": [
        "Text value"
    ],
    "Models": [
        "Text value"
    ],
    "OperatingSystems": [
        {
            "DeviceType": "Android",
            "Operator": "GreaterThan",
            "Value": "Android 2.2.1"
        }
    ],
    "UserAdditions": [
        {
            "Id": "512",
            "Name": "TestUser"
        }
    ],
    "DeviceAdditions": [
        {
            "Id": "123",
            "Model": "Android",
            "Username": "awuser"
        }
    ],
    "UserExclusions": [
        {}
    ],
    "DeviceExclusions": [
        {}
    ],
    "UserGroupExclusions": [
        {}
    ],
    "ManagementTypes": [
        "Text value"
    ],
    "EnrollmentCategories": [
        "Text value"
    ],
    "OEMAndModels": [
        {
            "OEM": {
                "Id": "123",
                "Name": "Dell"
            },
            "Models": [
                {
                    "Id": "123",
                    "Name": "Dell XPS 15"
                }
            ]
        }
    ],
    "CPUArchitectures": [
        "Text value"
    ]
}

    #>
}