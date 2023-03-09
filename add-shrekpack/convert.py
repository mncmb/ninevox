import json
with open("add-shrekpack/usernames.txt","r") as userf:
    users= userf.readlines()
#print (users)

shrekdict = dict()
shrekdict["users"] = list()
shrekdict["groups"] = dict()
shrekdict["ou"] = set()
groups = dict()
oucountry = dict()

def parse_shrektxt(filename, ouname):
    shrekdict["groups"][ouname] = set()
    with open(filename,"r") as shrektext:
        fairylocation= shrektext.readlines()
    for fairygroup in fairylocation:
        shrekdict["ou"].add(ouname)
        groupname, groupmembers = fairygroup.split(":")
        groupname= groupname.strip()
        oucountry[groupname] = ouname
        shrekdict["groups"][ouname].add(groupname)
        groups[groupname] = list()
        groupmembers = groupmembers.split(",")
        for member in groupmembers:
            member = member.strip().replace(" ", ".")
            groups[groupname].append(member.lower())

parse_shrektxt("add-shrekpack/duloc.txt", "duloc")
parse_shrektxt("add-shrekpack/far_far_away.txt", "far_far_away")
parse_shrektxt("add-shrekpack/san_ricardo.txt", "san_ricardo")
parse_shrektxt("add-shrekpack/swamp.txt", "swamp")


for user in users:
    userentry = dict()
    candidateOU = list()
    user = user.strip().replace(" ", ".")
    userentry["username"] = user
    userentry["password"] = ""
    userentry["description"] = "sHrEkPaCK"
    userentry["groups"] = list()
    for grp in groups.keys():
        if user.lower() in groups[grp]:
            userentry["groups"].append(grp)
            candidateOU.append(grp)
    
    shrekdict["users"].append(userentry)
    # determine OU based on some ranking
    if "residents" in candidateOU:
        userentry["ou"] = oucountry["residents"]
    elif "monarchs" in candidateOU:
        userentry["ou"] = oucountry["monarchs"]
    elif "rulers" in candidateOU:
        userentry["ou"] = oucountry["rulers"]   
    elif "people" in candidateOU:
        userentry["ou"] = oucountry["people"]
    elif candidateOU:
        userentry["ou"] = oucountry[candidateOU[0]]
    else:
        userentry["ou"] = ""
    # do some special user stuff
    if user.lower() == "donkey":
        userentry["password"] = "Passw0rd!"  
        userentry["description"] = "                                                                                                                         My Password was Passw0rd!"
    if user.lower() == "shrek":
        userentry["password"] = "Swamp2023!"
        userentry["groups"].append("Domain Admins")
        userentry["groups"].append("Enterprise Admins")

# convert set to list so that json dump works
for ou in shrekdict["groups"].keys():
    shrekdict["groups"][ou] = list(shrekdict["groups"][ou])
shrekdict["ou"] = list(shrekdict["ou"])

with open('add-shrekpack/user_data.json', 'w', encoding='utf-8') as f:
    json.dump(shrekdict, f, ensure_ascii=False, indent=4)