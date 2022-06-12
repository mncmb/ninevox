# windows AD test lab
- inspired by [detectionlab](https://www.detectionlab.network/) and [red team attack lab](https://www.google.com/search?channel=nrow5&client=firefox-b-d&q=marshall+hallenbeck+red+team+lab)
- slight shrek theming
- aims to include classic AD misconfigs & basic info on why and how these occur

## TODO
- description with pics howto create GPOs
- description howto backup GPOs
- add fileserver
- add application (for constr/unconstr deleg)
- add mssql
- add exchange
- add domain joined linux 
- refactor/ put info in json/yaml
- smthg smthg tooling & obfusc to bypass defender
- dev machine
- trusts & 2nd domain

## turn off sample submission via GPO 
- navigate to `Policies -> Administrative Templates -> Windows Components -> Microsoft Defender Antivirus -> MAPS`
- `Enable` the `Send file samples when further analysis is required` Setting and select `Always prompt`
- see alse [microsoft docs](https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/use-group-policy-microsoft-defender-antivirus?view=o365-worldwide)