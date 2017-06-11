---
external help file: PSChromeProfile-help.xml
online version: 
schema: 2.0.0
---

# Get-ChromeProfile

## SYNOPSIS
Get a list of Chrome profiles

## SYNTAX

### Name (Default)
```
Get-ChromeProfile [[-ProfileName] <String>] [<CommonParameters>]
```

### Id
```
Get-ChromeProfile [[-ProfileId] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will return list of chrome profiles found in chrome state file. 
Profiles can be filtered either by profile name or by profile ID.  

## EXAMPLES

### Example 1
```
PS C:\> Get-ChromeProfile -Id Default'

Id      Name
--      ----
Default Artem
```

Get default profile and its name

## PARAMETERS

### -ProfileId
Get profiles by their IDs. This is actually names of a profile folder.

```yaml
Type: String
Parameter Sets: Id
Aliases: 

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
Get profiles by their name.  Note that Chrome allows profiles with identical 
names so function will return only first of matching profiles

```yaml
Type: String
Parameter Sets: Name
Aliases: 

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS

