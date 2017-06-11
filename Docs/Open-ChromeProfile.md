---
external help file: PSChromeProfile-help.xml
online version: 
schema: 2.0.0
---

# Open-ChromeProfile

## SYNOPSIS
Launch Chrome with certain profile

## SYNTAX

### Name (Default)
```
Open-ChromeProfile [[-ProfileName] <String>] [[-Link] <String>] [<CommonParameters>]
```

### Id
```
Open-ChromeProfile [-ProfileId <String>] [[-Link] <String>] [<CommonParameters>]
```

## DESCRIPTION
Launch chrome browser with certain profile. You can also path a URL that will be opened.  

Supports tabcompletion for `-ProfileName` and `-ProfileId` with TabExapnsionPlusPlus

## EXAMPLES

### Example 1
```
PS C:\> Open-ChromeProfile -ProfileId Default -Link google.com
```

Open google.com with default profile

## PARAMETERS

### -Link
Site or URL that will be opened

```yaml
Type: String
Parameter Sets: (All)
Aliases: URL

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileId
Profile ID you want to open. Tabexpansion will show profile names in completion list.

```yaml
Type: String
Parameter Sets: Id
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
{{Fill ProfileName Description}}

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

## NOTES

## RELATED LINKS

