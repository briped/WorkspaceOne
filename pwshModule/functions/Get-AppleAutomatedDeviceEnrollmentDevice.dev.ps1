<#
/dep/groups/{groupUuid}/devices
New - Gets all Apple Automated Device Enrollment devices at organization group.

Returns all the Apple Automated Device Enrollment devices that have been synced into AirWatch for the given organization group.

groupUuid *
string
(path)
Organization group UUID to perform the operation on.(Required)



/dep/profiles/{profileUuid}/devices
New - Gets all Apple Automated Device Enrollment devices assigned to the profile.

Returns all the Apple Automated Device Enrollment devices that have been synced into AirWatch and assigned to the given profile unique key.
profileUuid *
string
(path)
Automated Device Enrollment profile unique key to get the device list for.(Required)

profileUuid
Page
integer
(query)
Specific page number to get. 0 based index

Default value :

Page
PageSize
integer
(query)
Maximum records per page. Default 500

Default value :

PageSize

#>