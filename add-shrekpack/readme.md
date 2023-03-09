- https://github.com/WazeHell/vulnerable-AD
- https://github.com/dievus/ADGenerator
- https://github.com/davidprowe/BadBlood
- [john hammond user creation AD](https://www.youtube.com/watch?v=59VqS6wMn6w)
- [Game of Active Directory](https://github.com/Orange-Cyberdefense/GOAD)
- [detectionlab deploy - cpassword](https://github.com/michiiii/DetectionLab-Deploy-Env) 
- [group managed service accounts](https://github.com/rgl/windows-domain-controller-vagrant)
- [Microsoft Post on passwd notreqd attribute](https://learn.microsoft.com/de-de/archive/blogs/russellt/passwd_notreqd) - essentially configure user to not require password
- [GPO vuln cpasswords](https://support.microsoft.com/en-au/topic/ms14-025-vulnerability-in-group-policy-preferences-could-allow-elevation-of-privilege-may-13-2014-60734e15-af79-26ca-ea53-8cd617073c30)
- [printernightmare](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-34527?WT.mc_id=M365-MVP-6771)


### cpassword
- [cpassword example adsecurity](https://adsecurity.org/?p=2288)
```xml
<?xml version="1.0" encoding="utf-8" ?>
<Groups clsid="{3125E937-EB16-4b4c-9934-544FC6D24D26}">
	<User clsid="{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}" name="Administrator (built-in)" image="2" changed="2015- 02-18 01:53:01" uid="{D5FE7352-81E1-42A2-B7DA-118402BE4C33}">
		<Properties action="U" newName="ADSAdmin" fullName="" description="" cpassword="RI133B2W|2CiI0Cau1DtrtTe3wdFwzCIWB5PSAXXMDstchJt3bLOUie0BaZ/7rdQjugTonF3ZWAKa1iRvd4JGQ" changeLogon="0" noChange="0" neverExpires="0" acctDisabled="0" subAuthority="RID_ADMIN" userName="Administrator (built-in)" expires="2015-02-17" />
	</User>
</Groups>
```

### mssql 
- https://www.youtube.com/watch?v=gHYhBHAv0BM
- https://www.youtube.com/watch?v=__rqszvU0zI